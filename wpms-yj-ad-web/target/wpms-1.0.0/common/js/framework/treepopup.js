$(function() {

    /**
     * 특정 inputBox에 나타나는 트리. 파라미터는 JSON 배열로 넘기도록 해야 함.
     * 선택시 h_[inputbox_ID]_treePopup 라는 hidden 태그에 값을 무조건 넣게 됨.
     * (히든 태그의 id/name은 기존 inputbox id가 k_로 시작하면 k_ 문자열을 떼고 h_ 로 바꿈)
     * $([inputbox_id]).data("treePopup") 으로 일부 메서드 사용 가능
     *
     * @param selectMode 체크박스 사용시 체크하는 방법 결정 (기본값=3)
     * @param clickEvent 클릭 이벤트 핸들러. 파라미터로 event(이벤트객체) 와 data(노드정보) 를 받음
     * @param dblClickEvent 더블 클릭 이벤트 핸들러. 파라미터로 event(이벤트객체) 와 data(노드정보) 를 받음
     * @param leafCheck 마지막 노드만 체크가 가능한지의 여부. false의 경우 체크박스가 없음. (기본값=false)
     * @param useText 선택(체크)시 선택 되어 있는 값들을 inputbox 에 표시할 때 text 값을 표시할 지의 여부 (기본값=false)
     */
    $.fn.treePopup = function(p_Param) {

        p_Param = p_Param || {};

        // selectMode == 1 : 1개만 선택 가능
        // selectMode == 2 : 단순히 여러 개 선택 가능
        // selectMode == 3 : 하나 선택시 하위 노드까지 선택 가능. 체크 해제시 상위노드의 체크 상태도 바뀜
        p_Param["selectMode"] = typeof(p_Param["selectMode"]) != 'undefined' ? p_Param["selectMode"] : 3;
        p_Param["clickEvent"] = typeof(p_Param["clickEvent"]) != 'undefined' ? p_Param["clickEvent"] : function() {};
        p_Param["dblClickEvent"] = typeof(p_Param["dblClickEvent"]) != 'undefined' ? p_Param["dblClickEvent"] : function() {};
        p_Param["checkbox"] = typeof(p_Param["checkbox"]) != 'undefined' ? p_Param["checkbox"] : false;
        p_Param["leafCheck"] = typeof(p_Param["leafCheck"]) != 'undefined' ? p_Param["leafCheck"] : false;

        p_Param["useText"] = typeof(p_Param["useText"]) != 'undefined' ? p_Param["useText"] : false;
        p_Param["readonly"] = typeof(p_Param["readonly"]) != 'undefined' ? p_Param["readonly"] : true;

        var obj = $(this);
        // 수정 불가능하게..
        obj.prop("readonly", p_Param["readonly"]).css({ "background-color" : "transparent" });

        var treeObj;
        // 전체를 감싸는 wrapper
        var wrap_all = $("<div id=\"" + obj.attr("id") + "_treePopup\" data-treePopup=\"" + obj.attr("id") + "_treePopup\"></div>");
        // 배경 div
        var wrap_bg = $("<div id=\"" + obj.attr("id") + "_treePopupBg\"></div>");
        // tree, 버튼 등을 감싸는 wrapper
        var wrapper = $("<div id=\"" + obj.attr("id") + "_treePopupTreeWrap\"></div>");
        // tree 가 표시될 div
        var treeShowObj = $("<div id=\"" + obj.attr("id") + "_treePopupTree\"></div>");
        // inputbox 의 절대적인 위치
        var position = getTagPosition(obj[0]);

        // hidden 태그 id
        var hidden_tag_id = obj.attr("id");
        hidden_tag_id = hidden_tag_id.indexOf("k_") == 0 ? hidden_tag_id.substring(2) : hidden_tag_id;
        hidden_tag_id = "h_" + hidden_tag_id + "_treePopup";

        // 값만 갖고 있는 hidden 태그 추가 (무조건 값만 들고 있으며, 콤마(,)로 구분함)
        if($("#" + hidden_tag_id).length < 1) {
            obj.parent().append("<input type=\"hidden\" name=\"" + hidden_tag_id + "\" id=\"" + hidden_tag_id + "\" />");
        }

        wrap_all.css({
            "display" : "none",
            "position" : "absolute",
            "left" : 0,
            "top" : 0,
            "width" : "100%",
            "height" : "100%"
        });

        wrap_bg.css({
            "display" : "block",
            "position" : "absolute",
            "left" : 0,
            "top" : 0,
            "z-index" : 10000,
            "border" : "0px solid #aaa",
            "width" : "100%",
            "height" : "100%",
            "background-color" : "transparent"
        });

        wrapper.css({
            "display" : "block",
            "position" : "absolute",
            "left" : position.x,
            "top" : position.y + 43,
            "z-index" : 10001,
            "border" : "1px solid #aaa",
            "width" : 300,
            "height" : 300,
            "background-color" : "white"
        });
        treeShowObj.css({
            "height" : 298,
            "overflow-y" : "auto"
        });
        wrapper.append(treeShowObj);
        wrap_all.append(wrapper);
        wrap_all.append(wrap_bg);
        $("body").append(wrap_all);

        // 트리 초기화
        treeObj = treeShowObj.initTree({
            "icon" : true,
            "expand" : true,
            "dnd" : false,
            "selectMode": p_Param["selectMode"],
            "convert" : {
                "key" : "id",
                "title" : "text",
                "folder" : "code_type"
            },
            "clickEvent" : function(event, data) {
                // 클릭 이벤트
                if(data.targetType == "title" || data.targetType == "icon") {
                    // 이름 클릭시..
                    if(data.node.key.length < 1) {
                        // 초기화 노드
                        $("#" + hidden_tag_id).val("");
                        obj.data("treePopup").hide();
                        obj.val("").removeClass("fill");
                        obj.data("treePopup").tree.unSelectAll();
                    }
                }

                p_Param["clickEvent"].call(null, event, data);
            },
            "dblClickEvent" : function(event, data) {
                // 더블클릭 이벤트
                if(data.targetType == "title" || data.targetType == "icon") {
                    if(!p_Param["leafCheck"] && !p_Param["checkbox"]) {
                        if(data.node.key.length > 0) {
                            if(p_Param["useText"]) {
                                obj.val(data.node.title).addClass("fill");
                            } else {
                                obj.val(data.node.key).addClass("fill");
                            }
                        }

                        $("#" + hidden_tag_id).val(data.node.key);
                        obj.data("treePopup").hide();
                    }
                }

                p_Param["dblClickEvent"].call(null, event, data);
            },
            "checkbox" : p_Param["checkbox"] == true ? function(event, data) {
                return data.node.key.length > 0;
            } : (p_Param["leafCheck"] == true ? function(event, data) {
                // 노드별 체크박스 사용 여부 리턴 (leafCheck == true 인 경우에만 마지막 노드에 체크박스를 사용하도록 함)
                return data.node.children == null && data.node.key.length > 0;
            } : false), //p_Param["checkbox"],
            "onCheckEvent": function(event, node) {
                // 체크박스가 있는 경우에 체크 표시를 했을 때의 이벤트
                if(obj.data("treePopup").tree.getCheckedText().length > 0) {
                    obj.addClass("fill");
                } else {
                    obj.removeClass("fill");
                }

                if(p_Param["useText"]) {
                    obj.val(obj.data("treePopup").tree.getCheckedText().join(","));
                } else {
                    obj.val(obj.data("treePopup").tree.getCheckedValue().join(","));
                }

                $("#" + hidden_tag_id).val(obj.data("treePopup").tree.getCheckedValue().join(","));
            },
            "offCheckEvent": function(event, node) {
                // 체크박스가 있는 경우에 체크 표시를 해제했을 때의 이벤트
                if(obj.data("treePopup").tree.getCheckedText().length > 0) {
                    obj.addClass("fill");
                } else {
                    obj.removeClass("fill");
                }

                if(p_Param["useText"]) {
                    obj.val(obj.data("treePopup").tree.getCheckedText().join(","));
                } else {
                    obj.val(obj.data("treePopup").tree.getCheckedValue().join(","));
                }

                $("#" + hidden_tag_id).val(obj.data("treePopup").tree.getCheckedValue().join(","));
            },
        });

        obj.data("treePopup", {
            // inputbox 에 객체를 넣어 일부 메서드를 사용할 수 있게 처리
            tree: treeObj,
            wrap: wrap_all,
            hide: function() {
                // 숨김
                this.wrap.css("display", "none");
            },
            show: function() {
                // 보여줌
                this.wrap.css("display", "block");
            },
            refresh: function(p_Data) {
                // 데이터 다시 세팅
                this.tree.refresh(p_Data);
            },
            getSelected: function() {
                // useText 세팅에 따라 값/텍스트 중 하나를 배열로 가지고 옴
                if(p_Param["useText"]) {
                    return this.tree.getCheckedText();
                } else {
                    return this.tree.getCheckedValue();
                }
            },
            getSelectedNode: function() {
                // 선택된 노드 자체를 배열로 가지고 옴
                return this.tree.getChecked();
            },
            getSelectedText: function() {
                // 선택된 노드의 텍스트를 배열로 가지고 옴
                return this.tree.getCheckedText();
            },
            getSelectedValue: function() {
                // 선택된 노드의 값(value)을 배열로 가지고 옴
                return this.tree.getCheckedValue();
            }
        }).focus(function() {
            // 다른 팝업은 다 닫아줌
            if($("div[data-treePopup]").length > 0) {
                $("div[data-treePopup]").css("display", "none");
            }

            // 이 팝업만 열어줌
            $(this).data("treePopup").show();
        });

        // 팝업 닫는 버튼
        $("#" + obj.attr("id") + "_treePopupClose").click(function() {
            obj.data("treePopup").hide();
        });

        // 배경 클릭시 닫기
        $("#" + obj.attr("id") + "_treePopupBg").click(function() {
            obj.data("treePopup").hide();
        });

        // 지우기 버튼
        $("#" + obj.attr("id") + "_treePopupErase").click(function() {
            obj.data("treePopup").tree.unSelectAll();
            obj.val("").removeClass("fill");
            $("#" + hidden_tag_id).val("");

            obj.data("treePopup").hide();
        });

        return this;
    };

});
