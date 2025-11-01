// 상수
window.initTree = window.initTree || {
    "MODE_SINGLE_SELECT" : 1,           // 1개만 선택 가능
    "MODE_MULTI_SELECT" : 2,            // 단순히 여러 개만 선택 가능
    "MODE_MULTI_HIER_SELECT" : 3        // 하나 선택시 하위 노드까지 선택 가능
};

$(function() {

    // var paramExample = {
    //     "icon" : false, // "icofont icofont-check" 처럼 class를 줄 수도 있음
    //     "clickEvent" : clickEvent,  // 단순 클릭 이벤트 함수명
    //     "checkEvent" : checkEvent,  // 체크박스의 값이 변경되었을 때의 이벤트 함수명
    //     "onCheckEvent" : onCheckEvent,  // 체크 되었을 때의 이벤트 함수명
    //     "offCheckEvent" : offCheckEvent, // 체크 해제 되었을 때의 이벤트 함수명
    //     "expand" : true, // 로딩시 펼쳐져 있을지의 여부
    //     "checkbox" : true, // 체크박스
    // };
    // fancyTreeObj = $("#treeDiv").treeInit(paramExample);
    $.fn.initTree = function(p_Param) {

        p_Param["clickEvent"] = typeof(p_Param["clickEvent"]) != 'undefined' ? p_Param["clickEvent"] : function() {};
        p_Param["dblClickEvent"] = typeof(p_Param["dblClickEvent"]) != 'undefined' ? p_Param["dblClickEvent"] : function() {};
        p_Param["checkEvent"] = typeof(p_Param["checkEvent"]) != 'undefined' ? p_Param["checkEvent"] : function() {};
        p_Param["onCheckEvent"] = typeof(p_Param["onCheckEvent"]) != 'undefined' ? p_Param["onCheckEvent"] : function() {};
        p_Param["offCheckEvent"] = typeof(p_Param["offCheckEvent"]) != 'undefined' ? p_Param["offCheckEvent"] : function() {};

        p_Param["icon"] = typeof(p_Param["icon"]) != 'undefined' ? p_Param["icon"] : false;
        p_Param["expand"] = typeof(p_Param["expand"]) != 'undefined' ? p_Param["expand"] : true;
        p_Param["checkbox"] = typeof(p_Param["checkbox"]) != 'undefined' ? p_Param["checkbox"] : false;

        p_Param["dnd"] = typeof(p_Param["dnd"]) != 'undefined' ? p_Param["dnd"] : false;
        p_Param["dndFinishEvent"] = typeof(p_Param["dndFinishEvent"]) != 'undefined' ? p_Param["dndFinishEvent"] : function() {};

        p_Param["convert"] = typeof(p_Param["convert"]) != 'undefined' ? p_Param["convert"] : {};

        p_Param["selectMode"] = typeof(p_Param["selectMode"]) != 'undefined' ? p_Param["selectMode"] : window.initTree.MODE_MULTI_HIER_SELECT;

        var obj = $(this);
        var retObj = {};
        var treeSetting = {};

        // 트리가 인식 가능한 데이터 형태로 변경하는 함수
        retObj.convertData = function(childList, expanded) {
            var parent,
                nodeMap = {};

            // Pass 1: store all tasks in reference map
            $.each(childList, function(i, c){
                nodeMap[c.id] = c;
            });
            // Pass 2: adjust fields and fix child structure
            childList = $.map(childList, function(c){
                // Rename 'key' to 'id'
                for(var key in p_Param["convert"]) {
                    if(key == "folder") {
                        c[key] = c[p_Param["convert"][key]] == "F" ? true : false;
                        delete c[p_Param["convert"][key]];
                    } else {
                        c[key] = c[p_Param["convert"][key]];
                        delete c[p_Param["convert"][key]];
                    }
                }
                // expanded : 하위 노드를 열 경우 true, 닫을 경우 false
                c.expanded = typeof(expanded) != 'boolean' ? true : expanded;
                // selected : (체크박스) 체크 여부
                // c.selected = (c.status === "completed");
                // Check if c is a child node
                if( c.parent && c.parent != "#" ) {
                    // add c to `children` array of parent node
                    parent = nodeMap[c.parent];
                    if( parent.children ) {
                        parent.children.push(c);
                    } else {
                        parent.children = [c];
                    }
                    return null;  // Remove c from childList
                }
                return c;  // Keep top-level nodes
            });

            return childList;
        };

        // 일반적인 세팅 값
        treeSetting = {
            checkbox: p_Param["checkbox"],
            selectMode: p_Param["selectMode"], // 1:single(1개 선택), 2:multi(그냥 선택만 됨), 3:multi-hier(하위 노드 중 하나라도 선택 안되면 상위 노드 선택 안되게 함) (default: 2)
            icon: p_Param["icon"],
            source: [],
            postProcess: function(event, data) {
                data.result = retObj.convertData(data.response, p_Param["expand"]);
            },
            click: function(event, data) {
                // 하위 노드를 보여주는 expander를 클릭한 경우를 제외
                if(data.targetType == "expander") {
                    // 하위 노드를 열어주는 버튼 클릭
                } else if(data.targetType == "icon") {
                    // 아이콘이 있는 경우 아이콘 클릭시
                } else {
                    p_Param["clickEvent"].call(null, event, data);
                }
            },
            dblclick: function(event, data) {
                p_Param["dblClickEvent"].call(null, event, data);
                return false;
            },
            select: function(event, data) {
                if(data.node.isSelected()) {
                    p_Param["onCheckEvent"].call(null, event, data);
                } else {
                    p_Param["offCheckEvent"].call(null, event, data);
                }

                p_Param["checkEvent"].call(null, event, data);
            },
            loadError: function (e, data) {
            	var error = data.error;
    			if (error.status && error.statusText) {
    				data.message = "Ajax error: " + data.message;
    				data.details = "Ajax error: " + error.statusText + ", status code = " + error.status;
    			} else {
    				data.message = "Custom error: " + data.message;
    				data.details = "An error occurred during loading: " + error;
    			}
    			
    			console.log(data.error);
            }
        };

        if(p_Param["dnd"] === true) {
            // 드래그 앤 드랍 활성화
            treeSetting["extensions"] = ["dnd5"];
            // 드래그 앤 드랍 설정
            treeSetting.dnd5 = {
                preventRecursion: true,
                preventVoidMoves: true,
                dragStart: function(node, data) {

                    retObj.dndBeforeParentNodeId = node.parent.key;
                    retObj.dndBeforeCurrentNodeIndex = 0;

                    for(var i = 0; i < node.parent.children.length; i++) {
                        if(node.parent.children[i].key == node.key) {
                            retObj.dndBeforeCurrentNodeIndex = i + 1;
                            break;
                        }
                    }

                    // Set the allowed effects (i.e. override the 'effectAllowed' option)
                    data.effectAllowed = "all";

                    // Set a drop effect (i.e. override the 'dropEffectDefault' option)
                    // data.dropEffect = "link";
                    data.dropEffect = "copy";

                    return true;
                },
                dragEnter: function(node, data) {
                    // data.dropEffect = "copy";
                    return true;
                },
                dragOver: function(node, data) {
                    // Assume typical mapping for modifier keys
                    data.dropEffect = data.dropEffectSuggested;
                    // data.dropEffect = "move";
                },
                dragDrop: function(node, data) {
                    /* This function MUST be defined to enable dropping of items on the tree. */
                    var newNode,
                        transfer = data.dataTransfer,
                        sourceNodes = data.otherNodeList,
                        mode = data.dropEffect,
                        childIdx = -1;

                    // node.debug( "T1: dragDrop: effect=" + "data: " + data.dropEffect + "/" + data.effectAllowed +
                    //     ", dataTransfer: " + transfer.dropEffect + "/" + transfer.effectAllowed, data );

                    // alert("Drop on " + node + ":\n"
                    //     + "source:" + JSON.stringify(data.otherNodeData) + "\n"
                    //     + "hitMode:" + data.hitMode
                    //     + ", dropEffect:" + data.dropEffect
                    //     + ", effectAllowed:" + data.effectAllowed);

                    if( data.hitMode === "after" ) {
                        // If node are inserted directly after tagrget node one-by-one,
                        // this would reverse them. So we compensate:
                        sourceNodes.reverse();
                    }
                    if (data.otherNode) {
                        // Drop another Fancytree node from same frame (maybe a different tree however)
                        var sameTree = (data.otherNode.tree === data.tree);

                        if (mode === "move") {

                            // 같은 부모에서 몇 번째 인지 인덱스를 넣어서 반환
                            for(var i = 0; i < node.parent.children.length; i++) {
                                if(node.parent.children[i].key == node.key) {
                                    childIdx = i;
                                    break;
                                }
                            }
                            node.data.newIndex = childIdx;

                            p_Param["dndFinishEvent"].call(null, node, data);
                            // data.otherNode.moveTo(node, data.hitMode);
                        }
                    }

                    node.setExpanded();
                }
            };
        }

        // 트리 초기화
        retObj.tree = obj.fancytree(treeSetting);

        // 일반적인 [{}, {}, ...] 형태의 배열을 트리가 인식 가능한 배열로 변경하는 함수
        // [트리object].refresh(array) 의 형태로 사용
        retObj.refresh = function(data) {
            $.ui.fancytree.getTree("#" + $(this.tree[0]).attr("id")).reload(this.convertData([data], p_Param["expand"]));
        };

        // 체크된 노드만 배열로 리턴
        retObj.getChecked = function() {
            return $.ui.fancytree.getTree("#" + $(this.tree[0]).attr("id")).getSelectedNodes();
        };

        // 체크된 노드의 이름을 배열로 리턴
        retObj.getCheckedText = function() {
            var ret_ary = [];
            $.ui.fancytree.getTree("#" + $(this.tree[0]).attr("id")).getSelectedNodes().forEach(function(node, idx) {
                if(node.key.length > 0) {
                    ret_ary.push(node.title);
                }
            });
            return ret_ary;
        };

        // 체크된 노드의 값을 배열로 리턴
        retObj.getCheckedValue = function() {
            var ret_ary = [];
            $.ui.fancytree.getTree("#" + $(this.tree[0]).attr("id")).getSelectedNodes().forEach(function(node, idx) {
                if(node.key.length > 0) {
                    ret_ary.push(node.key);
                }
            });
            return ret_ary;
        };

        // 전체 체크
        retObj.selectAll = function() {
            $.ui.fancytree.getTree("#" + $(this.tree[0]).attr("id")).selectAll();
        };

        // 전체 체크 해제
        retObj.unSelectAll = function() {
            $.ui.fancytree.getTree("#" + $(this.tree[0]).attr("id")).selectAll(false);
        };

        // 특정 노드와 하위 모든 노드를 반환
        retObj.getAllChildNode = function(p_Id) {
            return $.ui.fancytree.getTree("#" + $(this.tree[0]).attr("id")).getNodeByKey(p_Id);
        };

        return retObj;
    };

});
