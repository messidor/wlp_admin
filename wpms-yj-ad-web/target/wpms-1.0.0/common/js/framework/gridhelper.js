$(function() {
});

function lookupGubnText(p_value){
    var returnStr = "";

    if(p_value == "C"){
        // 추가
        returnStr = "추가";
    }
    else if(p_value == "U"){
        // 수정
        returnStr = "수정";
    }
    else if(p_value == "D"){
        // 삭제
        returnStr = "삭제";
    }
    else if(p_value == "A"){
        // 확정
        returnStr = "확정";
    }
    else if(p_value == "R"){
        // 확정취소
        returnStr = "확정취소";
    }
    else if(p_value == "RT"){
        // 반품
        returnStr = "반품";
    }
    else if(p_value == "RC"){
        // 반품취소
        returnStr = "반품취소";
    }
    else if(p_value == "OT"){
        // 출고취소
        returnStr = "출고취소";
    }
    else if(p_value == "OC"){
        // 재출고
        returnStr = "재출고";
    }
    else if(p_value == "DT"){
        // 출하
        returnStr = "출하";
    }
    else if(p_value == "DC"){
        // 미출하
        returnStr = "미출하";
    }
    else if(p_value == "CT"){
        // 완료보고
        returnStr = "완료보고";
    }
    else if(p_value == "CC"){
        // 완료보고취소
        returnStr = "완료보고취소";
    }

    return returnStr;
}

function lookupGubnValue(p_text){
    var returnStr = "";

    if(p_text == "추가"){
        // 추가
        returnStr = "C";
    }
    else if(p_text == "수정"){
        // 수정
        returnStr = "U";
    }
    else if(p_text == "삭제"){
        // 삭제
        returnStr = "D";
    }
    else if(p_text == "확정"){
        // 확정
        returnStr = "A";
    }
    else if(p_text == "확정취소"){
        // 확정취소
        returnStr = "R";
    }
    else if(p_text == "반품"){
        // 반품
        returnStr = "RT";
    }
    else if(p_text == "반품취소"){
        // 반품취소
        returnStr = "RC";
    }
    else if(p_text == "출고취소"){
        // 출고취소
        returnStr = "OT";
    }
    else if(p_text == "재출고"){
        // 재출고
        returnStr = "OC";
    }
    else if(p_text == "출하"){
        // 출하
        returnStr = "DT";
    }
    else if(p_text == "미출하"){
        // 미출하
        returnStr = "DC";
    }
    else if(p_text == "완료보고"){
        // 완료보고
        returnStr = "CT";
    }
    else if(p_text == "완료보고취소"){
        // 완료보고취소
        returnStr = "CC";
    }

    return returnStr;
}

function lookupComText(p_orgin, p_value){
    var returnStr = "";
    for(var k in p_orgin) {
        if(p_orgin[k]['value'] == p_value){
            returnStr = p_orgin[k]["text"];
        }
     }

    return returnStr;
}

function lookupComValue(p_orgin, p_text){
    var returnStr = "";
    for(var k in p_orgin) {
        if(p_orgin[k]['text'] == p_text){
            returnStr = p_orgin[k]["value"];
        }
     }

    return returnStr;
}

function setGridHeight(_id) {
    var calcHeight = gridContentHeight();

    if (calcHeight > 100) {
        if ($("#" + _id).attr("data-autosize") != "false") {
            if (typeof($("#" + _id).attr("data-height")) != "undefined") {
                if ($("#" + _id).attr("data-height").indexOf("px") > -1) {
                    $("#" + _id).height($("#" + _id).attr("data-height").replace("px",""));
                } else if ($("#" + _id).attr("data-height").indexOf("%") > -1) {
                    $("#" + _id).height(calcHeight * (Number($("#" + _id).attr("data-height").replace("%","")) / 100));
                }
            } else {
                $("#" + _id).height(calcHeight);
            }
        }
    } else {
        if (typeof($("#" + _id).attr("data-height")) != "undefined") {
            if ($("#" + _id).attr("data-height").indexOf("px") > -1) {
                $("#" + _id).height($("#" + _id).attr("data-height").replace("px",""));
            } else if($("#" + _id).attr("data-height").indexOf("%") > -1) {
                $("#" + _id).height(calcHeight * (Number($("#" + _id).attr("data-height").replace("%","")) / 100));
            }
        } else {
            $("#" + _id).height(calcHeight);
        }
    }
}


var SELECT_DATA = {};
function clearSelectData() {
	SELECT_DATA = {};
}

function getSelectData(_type, _data, _grid, _isCustom) {
    if (_isCustom === undefined) {
    	_isCustom = _grid;
        _grid = _data;
        _data = _type;
        _type = "all";
    }

    var _params = {};
    var cache_id = _data["query_id"];
    _params["query_id"] = _data["query_id"];
    $.each(_data["params"], function(k, v) {
    	if (v.startsWith("#")) {
    		v = v.substring(1);
    		cache_id += "/" + $("#" + v).val();
            _params[v] = $("#" + v).val();
    	} else if (_grid.data[v] !== undefined) {
    		const temp = "k" + v.substring(0, 1).toUpperCase() + v.substring(1);
            _params[temp] = _grid.data[v];
            cache_id += "/" + _grid.data[v];
        }
    });

    const params = $.extend({
        "_token": $("meta[name='csrf-token']").prop("content"),
        "url" : "/walletfree-admin/common_select.do",
        "func": "IQ",
        "value_name": "value",
    }, _params);

    var result = [];
    if (_isCustom == "true") {
    	if (SELECT_DATA[cache_id] === undefined) {
    		SELECT_DATA[cache_id] = [];
    	}

        result = SELECT_DATA[cache_id];
    } else if (SELECT_DATA[cache_id] !== undefined) {
        result = SELECT_DATA[cache_id];
    } else {
        $.ajax({
            method: "POST",
            url: params["url"],
            data: params,
            dataType: "json",
            async: false,
            success: function(data, textStatus, jqXHR) {
                result = data;
                SELECT_DATA[cache_id] = data;
            },
            error: function(data, textStatus, errorThrown) {}
        });
    }

    if (_type == "value") {
        var temp = [];
        for(var v in result) {
            temp.push(result[v][params["value_name"]]);
        }
        return temp;
    } else {
        return result;
    }
}

// 구분 컬럼 세팅 함수
// 파라미터
// 1. 구분 컬럼의 너비 (기본 100)
// 2. 숨김 여부(true:숨김, false:보여줌(기본값))
// 3. 구분 컬럼의 최소 너비 (기본값 없음. 없는 경우 설정하지 않음)
function setGubunColumn(_width, _hidden, _minWidth){
    var returnStr;

    _width = _width || 100;
    _hidden = typeof(_hidden) != 'boolean' ? false : _hidden;

    returnStr = {
        headerName: "구분",
        width: _width,
        field: "state_col",
        filter: false,
        sortable: false,
        resize: false,
        hide: _hidden,
        cellRenderer: function(params){
            return lookupGubnText(params.value);
        },
        valueFormatter: function(params){
            return lookupGubnText(params.value);
        },
        cellStyle: function(params) {
        		if(params === undefined) params = {value: ""};

            if(params.value == "C"){
                // 추가
                return {backgroundColor: "#0f0",color:"#fff", 'text-align':"center"}
            }
            else if(params.value == "U"){
                // 수정
                return {backgroundColor: "#00f",color:"#fff", 'text-align':"center"}
            }
            else if(params.value == "D"){
                // 삭제
                return {backgroundColor: "#f00",color:"#fff", 'text-align':"center"}
            }
            else if(params.value == "A"){
                // 확정
                return {backgroundColor: "#b6ffb6",color:"#000", 'text-align':"center"}
            }
            else if(params.value == "R"){
                // 확정취소
                return {backgroundColor: "#ffb6b6",color:"#000", 'text-align':"center"}
            }
            else if(params.value == "RT"){
                // 반품
                return {backgroundColor: "#8bd2fd",color:"#000", 'text-align':"center"}
            }
            else if(params.value == "RC"){
                // 반품취소
                return {backgroundColor: "#ffb6b6",color:"#000", 'text-align':"center"}
            }
            else if(params.value == "OT"){
                // 출고취소
                return {backgroundColor: "#8bd2fd",color:"#000", 'text-align':"center"}
            }
            else if(params.value == "OC"){
                // 재출고
                return {backgroundColor: "#ffb6b6",color:"#000", 'text-align':"center"}
            }
            else if(params.value == "DT"){
                // 출고취소
                return {backgroundColor: "#8bd2fd",color:"#000", 'text-align':"center"}
            }
            else if(params.value == "DC"){
                // 재출고
                return {backgroundColor: "#ffb6b6",color:"#000", 'text-align':"center"}
            }
            else if(params.value == "DT"){
                // 출하
                return {backgroundColor: "#8bd2fd",color:"#000", 'text-align':"center"}
            }
            else if(params.value == "DC"){
                // 미출하
                return {backgroundColor: "#ffb6b6",color:"#000", 'text-align':"center"}
            }
            else if(params.value == "CT"){
                // 완료보고
                return {backgroundColor: "#8bd2fd",color:"#000", 'text-align':"center"}
            }
            else if(params.value == "CC"){
                // 완료보고취소
                return {backgroundColor: "#ffb6b6",color:"#000", 'text-align':"center"}
            }

            else{
                return {backgroundColor: "transparent",color:"#000", 'text-align':"center"}
            }
        },
        pinned:"left",
        lockPosition: true,
        lockVisible: true
    }

    // 최소 너비의 경우, 값이 들어왔을 때에만 세팅하도록 처리함
    if(typeof(_minWidth) != 'undefined') {
        returnStr["minWidth"] = _minWidth;
    }

    return returnStr;
}

function setCheckBoxSelect(_width) {
    var returnStr;

    _width = _width || 50;

    returnStr = {
        headerName: "구분",
        width: _width,
        field: "check_col",
        cellRenderer: function(params){
            // var chk = document.createElement('input');
            // chk.type = "checkbox";
            // chk.checked = params.data.Select;
            // chk.addEventListener('change', function () {
            //     params.api.getFilterInstance('Select').resetFilterValues();
            // });
            // return chk;
        },
        filter: false,
        sortable: false,
        resize: false,
        //pinned:"left",
        //lockPosition: true,
        lockVisible: true,
        checkboxSelection: true
    }

    return returnStr;
}

// setColumn Overloading 처리 함수 ( 사용하지 않음 )
// object (Array, Object, MyObject), string, number, function, boolean
function setColumnVariable() {
    var _param1, _param2, _param3, _param4, _param5, _param6, _param7;

    for(var i=0; i<arguments.length; i++){
        eval("_param" + (i+1) + " = arguments[i];");
        // console.log(arguments[i].constructor == Array);
    }

    if(typeof(arguments[1]) == "object"){
        return setColumn(_param1, _param2, _param3, _param4, _param5, _param6, _param7);
    }
    else{
        return setColumnOver(_param1, _param2, _param3, _param4, _param5, _param6, _param7);
    }
}

function setColumnOver(_required, _hide, _rowDrag, _lockColumn, _addClass, _filter){
    return setColumn(_required, [], _hide, _rowDrag, _lockColumn, _addClass, _filter);
}

/*
    [*필드명, *헤더표시, 정렬, 너비],
    [편집여부(버튼클릭이벤트함수명),
            [입력종류("text", "select", "button", "check", "textarea"), JSON데이터, "값"필드명(버튼색깔-->primary,info,success,...), "표시텍스트"필드명(버튼텍스트), 버튼왼쪽아이콘클래스, 버튼오른쪽아이콘클래스],
        필수입력여부, 마스킹타입, 최대길이],
    숨김여부, 행드래그여부, 열잠금여부, 추가클래스(style문자열/함수명), 필터사용여부
*/
function setColumn(_required, _edit, _hide, _rowDrag, _lockColumn, _addClass, _filter) {
        // for(var i=0; i<arguments.length; i++){
        //     console.log(i);
        //     // console.log(arguments[i].constructor == Array);
        //     // console.log(typeof(arguments[i]));
        //     if(arguments[i].constructor == Array){
        //         for(var j=0; j<arguments[i].length; j++){
        //             console.log(typeof(arguments[i][j]));
        //         }
        //     }
        // }


    /*******************************************************************************
     * 오류 및 파라미터 처리
     *******************************************************************************/

    /**
     * 결과값
     */
    var resJson = {};

    var p_Required = _required || [];
    var p_Edit = _edit || [];

    if(p_Required.length < 2) {
        throw "setColumn: 첫번째 파라미터가 잘못되었습니다(최소 fieldName, headerName 필요).";
    }

    // 첫번째 파라미터 배열
    var p_FieldName = $.trim(p_Required[0]);        // 필수
    var p_HeaderName = $.trim(p_Required[1]);       // 필수
    var p_Align = p_Required.length >= 3 ? p_Required[2] : "left";
    var p_Width = p_Required.length >= 4 ? p_Required[3] : 100;
    // 두번째 파라미터 배열
    var p_Editable = p_Edit.length > 0 ? p_Edit[0] : false;             // 필수
    var p_InputTypeArray = p_Edit.length > 1 ? p_Edit[1] : [];      // 기본 text
    var p_InputRequired = p_Edit.length >= 3 && typeof(p_Edit[2]) == 'boolean' ? p_Edit[2] : false;
    var p_MaskType = p_Edit.length >= 4 ? ($.trim(p_Edit[3]) == "" ? "string" : $.trim(p_Edit[3])) : "string";
    var p_MaxLength = p_Edit.length >= 5 ? p_Edit[4] : "0";
    var p_CallBack = p_Edit.length >= 6 && typeof(p_Edit[5]) == 'function' ? p_Edit[5] : null;
    var p_Unique = p_Edit.length >= 7 && typeof(p_Edit[6]) == 'boolean' ? p_Edit[6] : false;
    // p_InputTypeArray 배열
    var p_InputType = p_InputTypeArray.length >= 1 ? ($.trim(p_InputTypeArray[0]).length > 0 ? $.trim(p_InputTypeArray[0]) : "text") : "text";
    var p_Data = p_InputTypeArray.length >= 2 ? p_InputTypeArray[1] : [];
    var p_ValueName = p_InputTypeArray.length >= 3 ? ($.trim(p_InputTypeArray[2]).length > 0 ? $.trim(p_InputTypeArray[2]) : "value") : "value";    // 버튼의 경우 data-btn-name 속성값으로 처리됨
    var p_TextName = p_InputTypeArray.length >= 4 ? ($.trim(p_InputTypeArray[3]).length > 0 ? $.trim(p_InputTypeArray[3]) : "text") : "text";       // 버튼의 경우 Caption 으로 처리됨
    var p_ButtonIconP = p_InputTypeArray.length >= 5 ? $.trim(p_InputTypeArray[4]) : ""; // 버튼의 경우 아이콘 클래스 (앞쪽)
    var p_ButtonIconS = p_InputTypeArray.length >= 6 ? $.trim(p_InputTypeArray[5]) : ""; // 버튼의 경우 아이콘 클래스 (뒤쪽)
    // 세번째 파라미터 배열
    var p_Hide = typeof(_hide) != 'boolean' ? false : _hide;
    var p_RowDrag = typeof(_rowDrag) != 'boolean' ? false : _rowDrag;
    var p_LockColumn = typeof(_lockColumn) != 'boolean' ? false : _lockColumn;
    var p_AddClass = _addClass || "";

    var p_Filter = typeof(_filter) != 'undefined' ? _filter : false;

    if(p_FieldName == "" || p_HeaderName == "") {
        throw "setColumn: 첫번째 파라미터가 잘못되었습니다(최소 fieldName, headerName 필요).";
    }

    if (p_Editable == false && p_InputRequired == true) {
    	p_InputRequired = false;
    }

    //
    var use_editor = "";
    var data_array = []; // select, radio 의 경우 value 에 해당하는 값만 순서대로 배열로 만듬
    var json_array = p_Data; // select, radio 의 경우 text, value 값을 그대로 json 배열로 넣음

    switch(p_InputType){
        case "select":
        case "select_ajax":
            use_editor = "agPopupSelectCellEditor";
            break;
        case "date":
        case "month":
        case "year":
            use_editor = "dateOnlyPicker";
            break;
        // case "datetime":
        //     use_editor = "dateTimePicker";
        //     break;
        // case "timeonly":
        //     use_editor = "timeOnlyPicker";
        //     break;
        case "radio":
            use_editor = "radioPicker";
            break;
        case "row_radio":
            use_editor = "rowRadioPicker";
            break;
        case "check":
            use_editor = "checkBoxPicker";
            break;
        case "textarea":
            use_editor = "agLargeTextCellEditor";
            break;
        case "text":
            // if(p_Required == true) {
            //     use_editor = "inputBoxPicker";
            // } else {
            //     use_editor = "";
            // }
            use_editor = "inputBoxPicker";
            break;
        default:
            use_editor = "inputBoxPicker";
            break;
    }

    for(var v in p_Data) {
        data_array.push(p_Data[v][p_ValueName]);
    }

    var tmp = p_MaxLength;
    var last_length = 0;
    var num_length = 0;
    var dec_length = 0;

    if(tmp.indexOf(".") > -1) {
        tmp = tmp.replace(/[^0-9.]/gi, "");
        tmp = tmp.split(".");

        if(typeof(tmp) == "object") {
            for(var i = 0; i < tmp.length; i++) {
                tmp[i] = parseInt(tmp[i], 10);
                tmp[i] = isNaN(tmp[i]) ? 0 : tmp[i];
                last_length += tmp[i];
            }
            num_length = tmp[0];
            dec_length = tmp[1];
            last_length++;
        } else {
            tmp = parseInt(tmp, 10);
            tmp = isNaN(tmp) ? 0 : tmp;
            last_length = tmp;

            num_length = tmp;
            dec_length = 0;
        }
    } else {
        last_length = parseInt(tmp, 10);
        last_length = isNaN(last_length) ? 0 : last_length;
    }

    /*******************************************************************************
     * 리턴값 처리
     *******************************************************************************/

    resJson = {
        headerName: p_HeaderName,
        field: p_FieldName,
        width: p_Width,
        minWidth: p_Width,
        cellRenderer: function(params) {
            // show_value 는 string 형태로 변환이 되어 있기 때문에 원래 값인 params.value 를 체크하도록 함
            var show_value = (params.value == null) ? "" : params.value;
            var ret_html = "";

            // masktype 처리
            if(p_MaskType == "string") {
                // 일반 스트링은 아무 처리 안함
            } else if(p_MaskType.indexOf("#,###") > -1) {

                var numstr = p_MaskType.split(".");
                var num = parseFloat(show_value);
                var dotNum = 0;

                if(numstr.length > 1) {
                    dotNum = numstr[1].length;
                }

                if(p_MaskType.indexOf(".") > -1) {
                    show_value = (num + 0).toFixed(dotNum);
                } else {
                    show_value = show_value + "";
                }

                show_value = addCommas((show_value == "" ? "0" : show_value).replace(/[^0-9.]/gi, ""), false, dotNum);
            } else if(p_MaskType == "dateonly") {
                if(show_value.length == 8) {
                    show_value = show_value.replace(/(\d{4})(\d{2})(\d{2})/, '$1-$2-$3');
                }
            } else {
                show_value = moment(show_value).format(p_MaskType);
            }

            switch(p_InputType) {
                case "select_ajax":
                    show_value = lookupComText(getSelectData(p_Data, params, p_ButtonIconP), show_value);
                    ret_html = '<span title="' + show_value + '">' + show_value + '</span>';

                    break;
                case "select":
                case "radio":
                    show_value = lookupComText(p_Data, show_value);

                    ret_html = '<span title="' + show_value + '">' + show_value + '</span>';
                    break;
                case "row_radio":
                    ret_html = '<i class="fas ' + (show_value == "Y" ? "fa-check-circle color-success-over" : "fa-times color-danger-over") + ' fa-lg"></i>';
                    break;
                case "check":
                    ret_html = '<i class="fas ' + (show_value == "Y" ? "fa-check color-success-over" : "fa-times color-danger-over") + ' fa-lg"></i>';
                    break;

                case "button":
                    // 버튼인 경우 5번째, 6번째 배열값이 각각 앞/뒤로 붙는 아이콘 클래스이며, 버튼이 아니면 이 값은 의미가 없다.
                    // 버튼의 경우 파라미터 순서
                    // 1. 버튼 ("button")
                    // 2. ("") <-- 고정
                    // 3. 버튼의 색깔 (primary, info, danger, warning, success 등)
                    // 4. 버튼 텍스트
                    // 5. 버튼 텍스트의 앞에 붙는 아이콘의 클래스
                    // 6. 버튼 텍스트의 뒤에 붙는 아이콘의 클래스
                    // 예) ["button", "", "danger", "삭제", "fa fa-times", "fa fa-user"]
                    p_ValueName = p_ValueName == "" || p_ValueName == "value" ? "primary" : p_ValueName;

                    var show_link_color = show_value.split(' ')[1] === undefined ? "" : show_value.split(' ')[1];
                    show_value = show_value.split(' ')[0] === undefined ? show_value : show_value.split(' ')[0];
                    var btn = document.createElement("button");
                        btn.className = "btn btn-sm waves-effect waves-light btn-" + p_ValueName + " grid-btn";
                        btn.setAttribute("data-value", show_value);
                        if(show_link_color != ""){
                        	btn.setAttribute( "style", "color:"+show_link_color);
                        }
                        btn.innerHTML =
                                (p_ButtonIconP != "" ? "<i style=\"margin:0px\" class=\"" + p_ButtonIconP + "\"></i>" + (p_TextName == "text" ? "" : "&nbsp;") : "") +
                                (p_TextName == "text" ? show_value : p_TextName) +
                                (p_ButtonIconS != "" ? (p_TextName == "text" ? "" : "&nbsp;") + "<i style=\"margin:0px\" class=\"" + p_ButtonIconS + "\"></i>" : "");

                        params.data["rowIndex"] = params.rowIndex;
                        btn.addEventListener("click", function(ev) {
                            p_Editable.call(null, ev, params.data);
                        });
                    ret_html = btn;

                    break;
                case "image":
                    const label = p_Data.label ? p_Data.label : "";
                    const width = p_Data.width ? p_Data.width : (p_Width ? p_Width : 100);
                    const height = p_Data.height ? p_Data.height : (width ? width : 100);

                    ret_html = "";

                    window.errorImg = function(obj) {
                        if ($(obj).attr("src") != "/images/no_image.png") {
                            $(obj).attr("src", "/images/no_image.png");
                        }
                        $(obj).closest("span").append($(obj).clone());
                        $(obj).parent().remove();
                    }

                    if (params.value) {
                        ret_html = '<a href="'+params.value+'" data-fancybox data-small-btn="true">';
                        ret_html += '   <img src="' + params.value + '" onError="errorImg(this);" style="width: ' + width + 'px !important; height: ' + height + 'px !important; max-width: ' + width + 'px !important; max-height: ' + height + 'px !important; vertical-align: unset;" alt="' + params.data[label] + '"/>';
                        ret_html += '</a>';
                    } else {
                        ret_html += '<img src="/images/no_image.png" style="width: ' + width + 'px !important; height: ' + height + 'px !important; max-width: ' + width + 'px !important; max-height: ' + height + 'px !important; vertical-align: unset;" alt="' + params.data[label] + '"/>';
                    }

                    break;
                default:
                    ret_html = '<span title="' + show_value + '">' + show_value + '</span>';
                    break;
            }

            return ret_html;
        },
        valueGetter: function(params) {
            if (p_InputType == "index") {
                if (p_Data == "desc") {
                    return params.api.getDisplayedRowCount() - params.node.rowIndex;
                } else {
                    return params.node.rowIndex + 1;
                }
            } else {
                return params.data[params.colDef.field] ? params.data[params.colDef.field] : "";
            }
        },
        valueFormatter: function(params) {
            if (p_InputType == "select") {
                return lookupComText(p_Data, params.value);
            } else if (p_InputType == "select_ajax") {
                if(params["data"] == null) {
                    const rows = params.api.getSelectedRows();
                    params["data"] = rows[0];
                }

                return lookupComText(getSelectData(p_Data, params, p_ButtonIconP), params.value);
            } else {
                return params.value;
            }
        },
        cellStyle: function(params) {
            var result = {"text-align": p_Align};

            if (p_InputType == "image") {
                result.padding = 0;
            }

            return result;
        },
        hide: p_Hide,
        rowDrag: p_RowDrag,
        lockVisible: true,
        inputType: p_InputType,
        maskType: p_MaskType,
        singleClickEdit: (p_InputType == "check" || p_InputType == "row_radio" ? true : false),
        filter: p_Filter,
        suppressMenu: true,
        // , floatingFilterComponent: "SelectFloatingFilter"
        floatingFilterComponentParams: {
            suppressFilterButton: true
        },
        unique: p_Unique
    };

    if(p_InputType == "button") {
        resJson["cellRendererParams"] = {
            onClick: p_ValueName,
            label: p_TextName
        };
    }

    if(p_InputType == "image") {
        resJson["imageOptions"] = p_Data;
        resJson["width"] = p_Width + 2;
        resJson["minWidth"] = p_Width + 2;
    }

    if(p_MaxLength != "" && p_MaxLength != "0") {
        if(last_length > 0) {
            resJson["maxLength"] = last_length;
        }
    }

    if(use_editor != "") {
        resJson["cellEditor"] = use_editor;
        if (p_InputType == "select_ajax") {
            resJson["cellEditorParams"] = function(params) {
                return {
                    values: getSelectData("value", p_Data, params, p_ButtonIconP),
                    datas: getSelectData(p_Data, params, p_ButtonIconP),
                    params: p_Data["params"],
                    queryId: p_Data["query_id"],
                    drawData: p_Data["draw_data"],
                    valueName : p_ValueName,
                    textName : p_TextName,
                };
            };
        } else if(p_InputType == "select" || p_InputType == "radio") {
            resJson["cellEditorParams"] = {
                values: data_array,
                datas: json_array,
                valueName : p_ValueName,
                textName : p_TextName,
                cellRenderer: function cellRenderer(params) {
                    return '<div style="display:inline-block;width:400px;">'+(params.value ? params.value : '')+'</div>';
                }
            };

            // resJson["singleClickEdit"] = true;
        } else if(p_InputType == "textarea") {
            if(last_length > 0) {
                resJson["cellEditorParams"] = {
                    maxLength: last_length,
                    cols: p_ValueName,
                    rows: p_TextName
                };
            }
        }
    }

    if(p_InputType != "button") {
        resJson["editable"] = p_Editable;
    }

    if(p_AddClass.length > 0) {
        if(typeof(p_AddClass) == "function"){
            resJson["cellClass"] = function(params){
                return eval(p_AddClass.name + "(params)");
            }
        }
        else{
            resJson["cellClass"] = p_AddClass;
        }
    }

    if(p_LockColumn == true) {
        resJson["pinned"]= "left";
    }

    if(p_InputRequired == true) {
        //resJson["cellEditor"] = "inputBoxPicker";
        resJson["required"] = true;
        resJson["headerClass"] = "grid-required-header";
        resJson["headerTooltip"] = resJson["headerName"] + ": 필수 항목";
        resJson["headerName"] = "* " + resJson["headerName"];
    }

    if(typeof(p_CallBack) == "function") {
        resJson["callback"] = p_CallBack;
    }

    return resJson;
}

function setColumnMask(p_ColDef, p_ColumnName, p_Type, p_Option) {
    if(typeof(p_Option) == 'undefined') {
        p_Option = {};
        p_Option["maxLength"] = 10;
        p_Option["decimal"] = 0;
    }

    p_Option["maxLength"] = typeof(p_Option["maxLength"]) != 'number' ? 10 : p_Option["maxLength"]; // 최대 길이
    p_Option["decimal"] = typeof(p_Option["decimal"]) != 'number' ? 0 : p_Option["decimal"];        // 숫자의 경우 소수점 길이
    p_Option["signed"] = typeof(p_Option["signed"]) != 'boolean' ? false : p_Option["signed"];      // 음수 사용 여부 (기본값: false)
    p_Option["decimalOption"] = p_Option["decimalOption"] || "round";                               // 버림/반올림/올림 옵션
    p_Option["decimalDisplay"] = typeof(p_Option["decimalDisplay"]) != 'boolean' ? true : p_Option["decimalDisplay"];       // 소수점 자리 맞춤 옵션

    p_Option["min"] = typeof(p_Option["min"]) != 'number' ? null : p_Option["min"];
    p_Option["max"] = typeof(p_Option["max"]) != 'number' ? null : p_Option["max"];


    // 없는 필드를 지정한 경우 콘솔 오류 처리.
    if(typeof(p_ColDef.find(function(elem) { return elem.field == p_ColumnName; })) == 'undefined') {
        throw ("setColumnMask: 해당하는 필드가 없습니다." + "(" + p_ColumnName + " / " + p_Type + ")");
    }

    // 해당 컬럼의 인덱스 (columnDef 에서의 index) 를 가지고 옴
    // 그리드 객체에 임시 변수를 할당하여 처리. 처리 후 삭제(delete)
    this.tempIndex = p_ColDef.findIndex(function(elem) { return elem.field == p_ColumnName; });

    // 마스킹 에디터로 변경
    if (p_Type != "date" && p_Type != "date2") {
    	p_ColDef[this.tempIndex]["cellEditor"] = "MaskingPicker";
    }

    // 추가 파라미터 할당
    p_ColDef[this.tempIndex]["cellEditorParams"] = {
        "type" : p_Type
    };

    switch(p_Type) {
        case "zip":
            p_ColDef[this.tempIndex]["cellEditorParams"]["maskType"] = [{
                mask: "00000"
            },{
                mask: "000-000"
            }];
            p_ColDef[this.tempIndex]["cellRenderer"] = function(params) {
                if(params.value != null) {
                    if(params.value.length == 6) {
                        return params.value.replace(/(\d{3})(\d{3})/, '$1-$2');
                    } else if(params.value.length == 5) {
                        return params.value.replace(/(\d{5})/, '$1');
                    } else {
                        return params.value;
                    }
                }
            };
            break;
        case "number": // 일반 숫자
            p_ColDef[this.tempIndex]["cellEditorParams"]["maskType"] = Number;
            p_ColDef[this.tempIndex]["cellEditorParams"]["decimal"] = p_Option["decimal"];
            p_ColDef[this.tempIndex]["cellEditorParams"]["maxLength"] = p_Option["maxLength"];
            p_ColDef[this.tempIndex]["cellEditorParams"]["decimalOption"] = p_Option["decimalOption"];
            p_ColDef[this.tempIndex]["cellEditorParams"]["decimalDisplay"] = p_Option["decimalDisplay"];
            p_ColDef[this.tempIndex]["cellEditorParams"]["signed"] = p_Option["signed"];
            p_ColDef[this.tempIndex]["comparator"] = function (number1, number2) {
                if (number1 === null && number2 === null) return 0;
                if (number1 === null) return -1;
                if (number2 === null) return 1;

                return number1 - number2;
            };
            p_ColDef[this.tempIndex]["cellRenderer"] = function(params) {
                if(params.value != null) {

                    if(params.value == "") {
                        params.value = "0";
                    }

                    if(parseFloat(params.value) == parseInt(params.value, 10)) {
                        // 정수부만 있으면..
                        return addCommas(params.value + "", false, params.colDef["cellEditorParams"]["decimal"]);
                    } else {
                        // 소수점도 있으면..
                    	/*
                    	 * Math.round에는 2번째 인자값이 없음.
                    	 * toFixed로 변경
                    	 * 210114 min0
                         */
                        if(params.colDef["cellEditorParams"]["decimalOption"] == "round") {
                            //return addCommas(Math.round(params.value, params.colDef["cellEditorParams"]["decimal"]), false, params.colDef["cellEditorParams"]["decimal"]);
                        	return addCommas(parseFloat(params.value).toFixed(params.colDef["cellEditorParams"]["decimal"]), false, params.colDef["cellEditorParams"]["decimal"]);
                        } else if(params.colDef["cellEditorParams"]["decimalOption"] == "ceil") {
                            return addCommas(Math.ceil(params.value * Math.pow(10, params.colDef["cellEditorParams"]["decimal"])) / Math.pow(10, params.colDef["cellEditorParams"]["decimal"]), false, params.colDef["cellEditorParams"]["decimal"]);
                        } else if(params.colDef["cellEditorParams"]["decimalOption"] == "floor") {
                            return addCommas(Math.floor(params.value * Math.pow(10, params.colDef["cellEditorParams"]["decimal"])) / Math.pow(10, params.colDef["cellEditorParams"]["decimal"]), false, params.colDef["cellEditorParams"]["decimal"]);
                        }
                    }
                } else {
                    return addCommas("0", false, params.colDef["cellEditorParams"]["decimal"]);
                }
            };
            break;
        case "phone": // 전화번호
            p_ColDef[this.tempIndex]["cellEditorParams"]["maskType"] = "00000000000";
            p_ColDef[this.tempIndex]["cellEditorParams"]["decimal"] = 0;
            p_ColDef[this.tempIndex]["cellRenderer"] = function(params) {
                if(params.value != null) {
                    if(params.value.length == 11) {
                        return params.value.replace(/(\d{3})(\d{4})(\d{4})/, '$1-$2-$3');
                    } else if(params.value.length == 8) {
                        return params.value.replace(/(\d{4})(\d{4})/, '$1-$2');
                    } else {
                        if(params.value.indexOf('02') == 0) {
                            if(params.value.length == 9){
                                return params.value.replace(/(\d{2})(\d{3})(\d{4})/, '$1-$2-$3');
                            }else if(params.value.length == 10){
                                return params.value.replace(/(\d{2})(\d{4})(\d{4})/, '$1-$2-$3');
                            }
                        } else {
                            return params.value.replace(/(\d{3})(\d{3})(\d{4})/, '$1-$2-$3');
                        }
                    }
                } else {
                    return "";
                }
            };
            break;
        case "saupja": // 사업자 등록번호
            p_ColDef[this.tempIndex]["cellEditorParams"]["maskType"] = "0000000000";
            p_ColDef[this.tempIndex]["cellEditorParams"]["decimal"] = 0;
            p_ColDef[this.tempIndex]["cellRenderer"] = function(params) {
                if(params.value != null) {
                    if(params.value.length == 10) {
                        return params.value.replace(/(\d{3})(\d{2})(\d{5})/, '$1-$2-$3');
                    } else {
                        return params.value;
                    }
                } else {
                    return "";
                }
            };
            break;
        case "time": // 시:분 형태의 문자열
            p_ColDef[this.tempIndex]["cellEditorParams"]["maskType"] = "0000";
            p_ColDef[this.tempIndex]["cellEditorParams"]["decimal"] = 0;
            p_ColDef[this.tempIndex]["cellRenderer"] = function(params) {
                if(params.value != null) {
                    if(params.value.length == 4) {
                        return params.value.replace(/(\d{2})(\d{2})/, '$1:$2');
                    } else {
                        return params.value;
                    }
                } else {
                    return "";
                }
            };
            break;
        case "time2": // 시:분:초 형태의 문자열
            p_ColDef[this.tempIndex]["cellEditorParams"]["maskType"] = "000000";
            p_ColDef[this.tempIndex]["cellEditorParams"]["decimal"] = 0;
            p_ColDef[this.tempIndex]["cellRenderer"] = function(params) {
                if(params.value != null) {
                    if(params.value.length == 6) {
                        return params.value.replace(/(\d{2})(\d{2})(\d{2})/, '$1:$2:$3');
                    } else {
                        return params.value;
                    }
                } else {
                    return "";
                }
            };
            break;
        case "date": // 년-월-일 형태의 문자열
            p_ColDef[this.tempIndex]["cellEditorParams"]["maskType"] = "00000000";
            p_ColDef[this.tempIndex]["cellEditorParams"]["decimal"] = 0;
            p_ColDef[this.tempIndex]["cellRenderer"] = function(params) {
                if(params.value != null) {
                	if (typeof params.value === "number" && params.value.toString().length == 13) {
                    	return moment(params.value).format("YYYY-MM-DD");
                	} else if(params.value.length == 8) {
                        return params.value.replace(/(\d{4})(\d{2})(\d{2})/, '$1-$2-$3');
                    } else {
                        return params.value;
                    }
                } else {
                    return "";
                }
            };
            break;
        case "date2": // 년-월 형태의 문자열
            p_ColDef[this.tempIndex]["cellEditorParams"]["maskType"] = "000000";
            p_ColDef[this.tempIndex]["cellEditorParams"]["decimal"] = 0;
            p_ColDef[this.tempIndex]["cellRenderer"] = function(params) {
                if(params.value != null) {
                	if (typeof params.value === "number" && params.value.toString().length == 13) {
                    	return moment(params.value).format("YYYY-MM");
                	} else if(params.value.length == 6) {
                        return params.value.replace(/(\d{4})(\d{2})/, '$1-$2');
                    } else {
                        return params.value;
                    }
                } else {
                    return "";
                }
            };
            break;
        case "datetime": // 년-월-일 시:분:초 형태의 문자열
            p_ColDef[this.tempIndex]["cellEditorParams"]["maskType"] = "00000000000000";
            p_ColDef[this.tempIndex]["cellEditorParams"]["decimal"] = 0;
            p_ColDef[this.tempIndex]["cellRenderer"] = function(params) {
                if (params.value != null) {
                	if (typeof params.value === "number" && params.value.toString().length == 13) {
                    	return moment(params.value).format("YYYY-MM-DD HH:mm:ss");
                	} else if (params.value.length == 14) {
                        return params.value.replace(/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/, '$1-$2-$3 $4:$5:$6');
                    } else {
                        return params.value;
                    }
                } else {
                    return "";
                }
            };
            break;
    }

    // 임시 변수 삭제
    delete this.tempIndex;

    return p_ColDef;
}

var initGrid = (function(){

    this.__gridOption;

    function initGrid(_columnDefs, _sizeFit, _newData, _changedFunc, _selectedFunc, _rowSelection){
        this.__editing = false;
        this.__columnDefs = _columnDefs;
        this.__selecetedRowIndex = -1;
        this.__sizeFit = _sizeFit || false;
        this.__newData = _newData;
        this.__changedFunc = _changedFunc;
        this.__selectedFunc = _selectedFunc;
        this.__rowSelection = _rowSelection || "multiple";
        this.__originalData = null;
    }

    initGrid.prototype = {
        setRowIndex : function(_index){
            this.__selecetedRowIndex = _index;
        },
        setGridOption: function(){
            var returnStr;
            var obj = $(this);

            returnStr = {
                setOriginalData : function(_origData) {
                    obj[0].__originalData = _origData;
                    clearSelectData();
                },
                //singleClickEdit: true,
                components: {
                    dateOnlyPicker: this.userDateOnlyPickerEditor(),
                    dateTimePicker: this.userDateOnlyPickerEditor(),
                    timeOnlyPicker: this.userDateOnlyPickerEditor(),
                    checkBoxPicker: this.userCheckBoxEditor(),
                    radioPicker: this.userRadioEditor(),
                    rowRadioPicker: this.userRowRadioEditor(),
                    inputBoxPicker: this.userInputBoxEditor(),
                    SelectFloatingFilter: this.SelectFloatingFilter(),
                    MaskingPicker: this.userMaskingPicker()
                },
                stopEditingWhenGridLosesFocus: true, // 그리드가 포커스를 잃으면 편집을 중지시키는 옵션
                enableBrowserTooltips: false, // 브라우저 기본 title 속성 사용 여부
                suppressDragLeaveHidesColumns: true,
                suppressPropertyNamesCheck: true,  // 커스텀 옵션 경고 미처리
                suppressColumnVirtualisation: true,
                enableCellTextSelection: true,
            	rowBuffer: 300,
                alignedGrids: [],
                defaultColDef: {
                    width: 100,
                    editable: false,
                    resizable: true,
                    sortable: true,
                    filter: false,
                    floatingFilter: false
                },
                columnDefs: this.__columnDefs,
                onGridReady: function(params) {
                    // 컬럼 자동 조절
                    if(obj[0].__sizeFit){
                        params.api.sizeColumnsToFit();
                    }

                    if(params.api.gridCore.gridOptions.rowHeight !== undefined && params.api.gridCore.gridOptions.rowHeight > 0) {
                        $("<style type='text/css'>").text("#" + params.api.gridCore.eGridDiv.id + " .ag-row .ag-cell { line-height: " + returnStr.rowHeight + "px } .ag-row .ag-cell-inline-editing { height: 100% !important; }").appendTo("head");
                    }
                },
                rowSelection: this.__rowSelection,
                animateRows: true,
                rowDragManaged: true,
                enableCellChangeFlash: true,
                onModelUpdated: function(event) {
                	$(".ag-row-drag").parents(".ag-cell-wrapper").css("display", "-webkit-box");
                },
                onRowEditingStarted: function(event) {
                    // console.log('never called - not doing row editing');
                },
                onRowEditingStopped: function(event) {
                    // console.log('never called - not doing row editing');
                },
                onCellEditingStarted: function(event) {
                    // console.log('cellEditingStarted');
                    this.__editing = true;
                    obj[0].setRowIndex(event.node.rowIndex);

                    obj[0].__gridOption.api.forEachNode( function (node) {
                        node.setSelected(false);
                        if (node.rowIndex === event.node.rowIndex) {
                            node.setSelected(true);
                        }
                    });


                    // 라디오 박스일 때 다른 라디오 박스들의 체크 상태를 해제하고 편집 상태를 바로 해제시킴
                    if(event.colDef.cellEditor == "radioPicker") {
                        //obj[0].__gridOption.api.stopEditing();
                    } else if(event.colDef.cellEditor == "checkBoxPicker") {
                        // 체크박스인 경우 편집 상태를 바로 해제시킴
                        obj[0].__gridOption.api.stopEditing();
                    } else if (event.colDef.cellEditor == "rowRadioPicker") {
                        // 체크박스인 경우 편집 상태를 바로 해제시킴
                        obj[0].__gridOption.api.stopEditing();

                        obj[0].__gridOption.enableCellChangeFlash = false;
                        event.api.forEachNode(function(rowNode) {
                           rowNode.setDataValue("check_value", rowNode.rowIndex == event.node.rowIndex ? "Y" : "N");
                        });
                        obj[0].__gridOption.enableCellChangeFlash = true;

                    } else if(event.colDef.cellEditor == "agPopupSelectCellEditor") {
                        $(".ag-wrapper.ag-picker-field-wrapper").trigger("click").parent().parent().parent().parent().hide();

                        var orgIdx = -1;
                        if (typeof event.colDef.cellEditorParams === "function") {
                            orgIdx = event.colDef.cellEditorParams(event).datas.findIndex(function(item){return item.value == event.value});
                        } else {
                            orgIdx = event.colDef.cellEditorParams.datas.findIndex(function(item){return item.value == event.value});
                        }

                        if (orgIdx > -1) {
                        	$(".ag-list.ag-select-list.ag-ltr.ag-popup-child").children("div:eq(" + orgIdx + ")").addClass("custom-ag-grid-selected-item");
                        }
                    }

                    $("button").not(".applyBtn").not(".cancelBtn").prop("disabled", true).css("cursor", "no-drop").attr("data-cell_edit", "disabled").attr("title", "그리드 편집 도중에는 사용할 수 없습니다.");
                    $("input,select").not("[disabled='disabled']").not(".ag-cell-edit-input").not(".daterangepicker input,.daterangepicker select").prop("disabled", true).css("cursor", "no-drop").attr("data-cell_edit", "disabled").attr("title", "그리드 편집 도중에는 사용할 수 없습니다.");
                },
                onCellEditingStopped: function(event) {
                    // console.log('cellEditingStopped');

                    if(event.colDef.field != "state_col") {

                        // this.row = obj[0].__gridOption.api.getSelectedRows();
                        this.row = obj[0].getGridRowData(obj[0].__selecetedRowIndex);

                        // this.rowNode = obj[0].__gridOption.api.getSelectedNodes();
                        this.rowNode = obj[0].__gridOption.api.getRowNode(obj[0].__selecetedRowIndex);

                        var diffValue = false;
                        if(typeof(this.rowNode) != 'undefined' && obj[0].__originalData) {
                            for(v in obj[0].__originalData[this.rowNode.id]) {
                                if (v == "state_col") continue;

                                if ((this.row[v] || "") != (obj[0].__originalData[this.rowNode.id][v] || "")){
                                    diffValue = true;
                                    break;
                                }
                            }
                        }

                        switch (event.colDef.inputType) {
                            case "email" :
                                const val = this.row[event.colDef.field];
                                const is_email = /^[0-9a-zA-Z]([-_\.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_\.]?[0-9a-zA-Z])*\.[a-zA-Z]{2,3}$/i.test(val);

                                if (val != "" && !is_email) {
                                    this.row[event.colDef.field] = "";

                                    obj[0].__gridOption.api.setFocusedCell(obj[0].__selecetedRowIndex, event.colDef.field);
                                    obj[0].__gridOption.api.startEditingCell({
                                        rowIndex: obj[0].__selecetedRowIndex,
                                        colKey: event.colDef.field
                                    });
                                    //obj[0].__gridOption.api.applyTransaction({update: [this.row]});

                                    notifyDanger("올바른 이메일 주소를 입력해 주세요." + " (test@ad.its.yeongju.kr)");

                                    return;
                                }

                                break;
                            case "select_ajax":
                                const data = event.colDef.cellEditorParams(event);

                                if (data["drawData"]) {
                                	for (var i=0; i<data.datas.length; i++) {
                                		if (data.datas[i].value == this.row[event.colDef.field]) {
                                			for (var key in data.datas[i]) {
                                    			if (key != "value" && key != "text") {
                                    				this.row[key] = data.datas[i][key];
                                    			}
                                			}
                                			break;
                                		}
                                	}

                                    obj[0].__gridOption.api.applyTransaction({update: [this.row]});
                                }
                            	break;
                            case "select":
                            	/*
                            	 * 연계 콤보일때 연계 값이 변경되면 선택된 값 공백 처리
                            	 */
                                for (var i in event.api.columnController.columnDefs) {
                                    const col = event.api.columnController.columnDefs[i];

                                    if (col.inputType == "select_ajax") {
                                        const data = col.cellEditorParams(event);

                                        for (var j in data.params) {
                                        	if (event.colDef.field == data.params[j]) {
                                        		this.row[col.field] = "";
                                                obj[0].__gridOption.api.applyTransaction({update: [this.row]});
                                        	}
                                        }
                                    }
                                }

                            	break;
                            default :;
                        }

                        if(event.colDef.unique) {
                      	    for(var i = 0; i < obj[0].getAllGridData().length; i++){
                      	    	if(i != event.rowIndex && obj[0].getAllGridData()[i][event.colDef.field] == this.row[event.colDef.field]) {

                      	    		event.api.applyTransaction({update: [this.row]});
                      	    		event.api.setFocusedCell(event.rowIndex, event.colDef.field);
                      	    		event.api.startEditingCell({
                      	                rowIndex: event.rowIndex,
                      	                colKey: event.colDef.field
                      	            });
                      	    		notifyDanger("중복된 데이터가 존재합니다.");
                      	    		return false;
                      	    	}
                      	    }
                        }

                        if (event.colDef.callback !== undefined && typeof(event.colDef.callback) == "function") {
                            if(event.colDef.callback(obj) == false) {
                                $("input[data-cell_edit],select[data-cell_edit]").not(".ag-cell-edit-input").not(".daterangepicker input,.daterangepicker select").prop("disabled", false).css("cursor", "default").removeAttr("data-cell_edit").attr("title", "");
                                $("button").not(".applyBtn").not(".cancelBtn").prop("disabled", false).css("cursor", "pointer").removeAttr("data-cell_edit").attr("title", "");

                                return;
                            }
                        }


                        if(diffValue) {
                            if(this.__editing) {
                                // console.log('onUpdateOneValue -> start');
                                this.row["state_col"] = "U";

                                for(var k in event.api.columnController.columnDefs) {
                                    const col = event.api.columnController.columnDefs[k];

                                    if (col.inputType == "select_ajax") {
                                        const data = col.cellEditorParams(event);

                                        if(data.params && data.params.length > 0) {
                                            var cache_id = data.queryId;

                                            for(var j in data.params) {
                                                cache_id += "/" + this.row[data.params[j]];

                                                if (data.params[j] == event.colDef.field) {
                                                	if (SELECT_DATA[cache_id] !== undefined && SELECT_DATA[cache_id].length > 0) {
                                                        this.row[col.field] = SELECT_DATA[cache_id][0][data.valueName];
                                                	} else {
                                                		this.row[col.field] = "";
                                                	}
                                                }
                                            }
                                        }
                                    }
                                }

                                obj[0].__gridOption.api.applyTransaction({update: [this.row]});
                                // console.log('onUpdateOneValue -> end');
                            }
                        } else if (this.row["state_col"] == "U" || this.row["state_col"] == "D") {
                            this.row["state_col"] = "";

                            obj[0].__gridOption.api.applyTransaction({update: [this.row]});
                        }

                    } else{
                        // console.log('onUpdateOneValue -> state_col');
                    }
                    this.__editing = false;

                    $("input[data-cell_edit],select[data-cell_edit]").not(".ag-cell-edit-input").not(".daterangepicker input,.daterangepicker select").prop("disabled", false).css("cursor", "default").removeAttr("data-cell_edit").attr("title", "");
                    $("button").not(".applyBtn").not(".cancelBtn").prop("disabled", false).css("cursor", "pointer").removeAttr("data-cell_edit").attr("title", "");
                },
                onCellValueChanged : function(event) {
                    //console.log('CellValueChanged');

                    if(typeof(obj[0].__changedFunc) == "function"){
                        //eval(obj[0].__changedFunc.name + "(event);");
                        obj[0].__changedFunc(event);
                    }
                },
                onSelectionChanged: function(event){
                    // console.log('SelectionChanged');
                },
                onRowSelected: function(event){
                    if(event.node.selected){
                        //console.log(event);
                        //this.__selecetedRowIndex = event.rowIndex;
                        //this[__selecetedRowIndex] = event.rowIndex;
                        obj[0].setRowIndex(event.rowIndex);
                        event.node.setSelected(true);

                        if(typeof(this.__selectedFunc) == "function"){
                            eval(this.__selectedFunc.name + "(event);");
                        }
                    } else {
                        event.node.setSelected(false, false);
                    }
                },
                onPaginationChanged: function(event) { 
                    const gridId = obj[0].__gridOption.api.gridCore.eGridDiv.id
                    const panel = $("#" + gridId + " .ag-paging-row-summary-panel");
                    const totalCount = obj[0].__gridOption.api.getDisplayedRowCount();

                    panel.html("검색 결과 : <span ref='lbRecordCount' class='ag-paging-row-summary-panel-number'>" + totalCount + "</span>건");
                },
                localeText: {noRowsToShow: "조회된 데이터가 없습니다."},
                checkValue: function() {
                    // 필수값이라고 처리되어 있는 컬럼마다 돌면서 처리
                    // state_col != "" 인 row만 체크

                    var colDef = obj[0].__gridOption.columnDefs;

                    // 리턴값
                    var return_value = {
                        input_ok: true, // 필수값 정상 입력 여부
                        req_column: "", // 미입력 필수값의 컬럼명
                        req_row: 0 // 미입력 필수값의 row 번호
                    };

                    var rnd_num = parseInt(Math.random() * 100 + 1, 10);

                    // forEachNode 에서 break, continue 가 없기 때문에 반복은 무조건 처리한다..
                    obj[0].__gridOption.api.forEachNode( function(node) {
                        // 필수값이 입력 안된 경우에는 체크 안하도록 처리해야 함
                        if(return_value["input_ok"] == true) {
                            for(v in node.data) {
                                var field_no = -1;
                                // 필드명으로 필드 index 를 가지고 옴
                                for(var i = 0; i < colDef.length; i++) {
                                    if(colDef[i]["field"] == v) {
                                        field_no = i;
                                        break;
                                    }
                                }
                                if(field_no > -1) {
                                    // 필수값이 지정된 경우에만 처리하도록 함
                                    if(typeof(colDef[field_no]["required"]) == 'boolean') {
                                        if(colDef[field_no]["required"] == true) {
                                            // state_col 값이 존재하고, 현재 체크하는 필드가 state_col 이 아닌 경우
                                            if(v != "state_col" && node["data"]["state_col"] != "") {
                                                // 값이 비어 있는 경우
                                                if($.trim(node.data[v]) == "") {
                                                    return_value["input_ok"] = false;
                                                    return_value["req_row"] = node["rowIndex"];
                                                    return_value["req_column"] = v;
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    });

                    return return_value;
                },
                getRowStyle:function(params) {
                    // 그리드 wrapper 의 아이디를 "grid" 속성값으로 넣어줌
                    params["grid"] = params.api.gridCore.eGridDiv.id;
                    if(typeof(rowStyle) == "function") {
                        return rowStyle(params);
                    } else {
                        return "";
                    }
                },
                pagination: false,
                paginationPageSize: 99999999999,
            }

            $.each(this.__columnDefs, function(k, v) {
                if (v.inputType && v.inputType == "image") {
                    const width = (v.imageOptions.width ? v.imageOptions.width : (v.width ? v.width : 100));
                    const height = v.imageOptions.height ? v.imageOptions.height : width;

                    if (returnStr.rowHeight === undefined || (returnStr.rowHeight > 0 && returnStr.rowHeight < height + 1)) {
                        returnStr.rowHeight = height + 3;//border 때문에 1 추가함
                    }
                }
            });

            this.__gridOption = returnStr;

            return returnStr;
        },
        getAllGridData: function() {
            var ret_data = [];
            this.__gridOption.api.forEachNode(function(rowNode, index) {
                ret_data.push(rowNode.data);
            });

            return ret_data;
        },
        getGridData: function(_rowIdx, _colName) {
            // 특정 row의 특정 컬럼에 세팅된 데이터를 받아옴
            return this.__gridOption.api.getModel().getRow(_rowIdx).data[_colName];
        },
        getGridRowData: function(_rowIdx, _colName) {
            // 특정 row의 데이터를 받아옴
            return this.__gridOption.api.getModel().getRow(_rowIdx).data;
        },
        setGridData: function(_rowIdx, _colName, _value, _changeState) {
            // setGridData([Row순번], [컬럼명], [설정할 값], [상태 변경 여부(true(기본값)/false)])
            // 1. state_col 이 있으면 자동으로 수정 상태로 변경함
            _changeState = typeof(_changeState) != 'undefined' ? _changeState : true;

            if(_changeState) {
                for(var i = 0; i < this.__gridOption.columnDefs.length; i++) {
                    if(this.__gridOption.columnDefs[i].field == "state_col") {
                        (this.__gridOption.api.getModel().getRow(_rowIdx)).setDataValue("state_col", "U");
                        break;
                    }
                }
            }

            (this.__gridOption.api.getModel().getRow(_rowIdx)).setDataValue(_colName, _value);
        },
        getSelectedRows: function() {
            // 모든 선택된 데이터를 배열과 JSON 배열 형태로 리턴. 없으면 [] 리턴함.
            var ret_ary = [];
            for(var i = 0; i < this.__gridOption.api.getSelectedNodes().length; i++) {
                ret_ary.push(this.__gridOption.api.getSelectedNodes()[i].data);
            }
            return ret_ary;
        },
        getCheckedRows: function(p_CheckRowName) {
            // 모든 체크된 데이터를 배열과 JSON 배열 형태로 리턴. 없으면 [] 리턴함.
            // 체크를 검사할 field 명을 넣어줘야 함
            var ret_ary = [];
            this.__gridOption.api.forEachNode(function(rowNode, index) {
                if(rowNode.data[p_CheckRowName] == "Y") {
                    ret_ary.push(rowNode.data);
                }
            });
            return ret_ary;
        },
        getSelectedNode: function(_selIdx) {
        	if (_selIdx === undefined) _selIdx = 0;

            // 모든 선택된 데이터를 배열과 JSON 배열 형태로 리턴. 없으면 "" 리턴함.
            // 선택된 row 에서의 idx를 입력해야 함
            if(this.__gridOption.api.getSelectedNodes().length > 0) {
            	return this.__gridOption.api.getSelectedNodes()[_selIdx];
            } else {
            	return {};
            }
        },
        getSelectedData: function(_selIdx, _colName) {
        	if (_selIdx === undefined) _selIdx = 0;

            // 모든 선택된 데이터를 배열과 JSON 배열 형태로 리턴. 없으면 "" 리턴함.
            // 선택된 row 에서의 idx를 입력해야 함
            if(this.__gridOption.api.getSelectedNodes().length > 0) {
            	if (_colName !== undefined) return this.__gridOption.api.getSelectedNodes()[_selIdx].data[_colName];
            	else return this.__gridOption.api.getSelectedNodes()[_selIdx].data;
            } else {
            	if (_colName !== undefined) return "";
            	else return {};
            }
        },
        setSelectedData: function(_colName, _value, _changeState) {
            // setSelectedData([컬럼명], [설정할 값], [상태 변경 여부(true(기본값)/false)])
            // 1. 선택 row가 없으면 동작하지 않음
            // 2. state_col 이 있으면 자동으로 수정 상태로 변경함

            _changeState = typeof(_changeState) != 'undefined' ? _changeState : true;

            if(this.__gridOption.api.getSelectedNodes().length > 0) {
                if(_changeState) {
                    for(var i = 0; i < this.__gridOption.columnDefs.length; i++) {
                        if(this.__gridOption.columnDefs[i].field == "state_col") {
                            (this.__gridOption.api.getSelectedNodes())[0].setDataValue("state_col", "U");
                            break;
                        }
                    }
                }
                (this.__gridOption.api.getSelectedNodes())[0].setDataValue(_colName, _value);
            }
        },
        getChangedRows: function() {
            var ret_ary = [];
            this.__gridOption.api.forEachNode(function(rowNode, index) {
                if(typeof(rowNode.data['state_col']) != 'undefined') {
                    if(rowNode.data['state_col'] != "") {
                        ret_ary.push(rowNode.data);
                    }
                }
            });
            return ret_ary;
        },
        onAddRow: function(){
            var newItem = this.__newData.call(null); //createNewRowData();
            var res = this.__gridOption.api.applyTransaction({add: [newItem]});
            this.printResult(res);
        },
        onAddRowSelected: function(p_Param){
            var res = this.__gridOption.api.applyTransaction({add: [p_Param]});
            this.printResult(res);
        },
        onRemoveSelected: function(){
            this.selectedData = this.__gridOption.api.getSelectedRows();

            if(this.selectedData.length < 1){
                alert("행이 선택되지 않았습니다.");
                return;
            }

            var removedRows = [];
            var changedRows = [];
            this.selectedData.forEach( function(selectedRow, index) {

                if(selectedRow.state_col == "C"){
                    removedRows.push(selectedRow);
                }
                else {
                    selectedRow.state_col = "D";
                    changedRows.push(selectedRow);
                }
            });

            this.__gridOption.api.applyTransaction({remove: removedRows});

            this.__gridOption.api.applyTransaction({update: changedRows});
        },
        onDeleteRow: function(){
            this.selectedData = this.__gridOption.api.getSelectedRows();

            if(this.selectedData.length < 1){
                alert("행이 선택되지 않았습니다.");
                return;
            }

            this.__gridOption.api.applyTransaction({remove: this.selectedData});
        },
        deleteRowIdx: function(_rowIdx) {
            // _rowIdx 는 삭제할 row 인덱스 번호
            // 예) _gridHelper.deleteRowIdx([0, 2, 4]);
            var obj = this;
            _rowIdx = _rowIdx || [];

            for(var i = 0; i < _rowIdx.length; i++) {
                obj.__gridOption.api.applyTransaction({remove: [obj.__gridOption.api.getModel().getRow(_rowIdx[i]).data]});
            }
        },
        deleteRow: function(_data) {
            var obj = this;
            obj.__gridOption.api.applyTransaction({remove: [_data]});
        },
        onUndoSelected: function() {
            // 선택된 row 개수가 없으면 경고 띄우고 아무것도 하지 않음
            if(this.getSelectedRows().length < 1) {
                alert("행이 선택되지 않았습니다.");
                return;
            }

            var removedRows = [];
            var colNode = [];
            var newValue = "";
            var obj = this;

            this.__gridOption.api.forEachNode( function(RowNode) {
                if(RowNode.selected){
                    if(RowNode.data.state_col == "C"){
                        removedRows.push(RowNode.data);
                    }
                    else if(RowNode.data.state_col == ""){
                    }
                    else{
                        for(v in obj.__originalData[RowNode.id]) {
                            colNode = [v];
                            newValue = obj.__originalData[RowNode.id][v];

                            if(typeof(RowNode.columnController.columnDefs.find(function(element) { return element.field == colNode; })) != 'undefined') {
                                RowNode.setDataValue(colNode, newValue);
                            }
                        }

                        colNode = ['state_col'];
                        newValue = "";

                        RowNode.setDataValue(colNode, newValue);
                    }
                }
            });

            this.__gridOption.api.applyTransaction({remove: removedRows});
            this.__editing = false;

            $("input[data-cell_edit],select[data-cell_edit]").not(".ag-cell-edit-input").not(".daterangepicker input,.daterangepicker select").prop("disabled", false).css("cursor", "default").removeAttr("data-cell_edit").attr("title", "");
            $("button").not(".applyBtn").not(".cancelBtn").prop("disabled", false).css("cursor", "pointer").removeAttr("data-cell_edit").attr("title", "");
        },
        addRowClickEvent: function(funcName){
            // row 1개 클릭 이벤트
            if(typeof(funcName) == "function") {
                this.__gridOption.onRowClicked = function(event) {
                    funcName.call(null, event);
                }
            }
        },
        addRowDblClickEvent: function(funcName){
            // row 1개 더블클릭 이벤트
            if(typeof(funcName) == "function") {
                this.__gridOption.onRowDoubleClicked = function(event) {
                    funcName.call(null, event);
                }
            }
        },
        clearData: function(grid) {
            this.__gridOption.api.setRowData([]);

            if (grid !== undefined) {
                setGridHeight($(grid).attr("id"));
            }
        },
        printResult: function(res){
            // console.log('---------------------------------------')
            if (res.add) {
                res.add.forEach( function(rowNode) {
                    // console.log('Added Row Node', rowNode);
                });
            }
            if (res.remove) {
                res.remove.forEach( function(rowNode) {
                    // console.log('Removed Row Node', rowNode);
                });
            }
            if (res.update) {
                res.update.forEach( function(rowNode) {
                    // console.log('Updated Row Node', rowNode);
                });
            }
        },
        clearSelection: function() {
            this.__gridOption.api.deselectAll();
        },
        // p_CheckState 가 true 인 경우 모두 체크, false 인 경우 모두 미체크 (기본 true)
        // p_ColumnName 은 변경할 체크박스가 있는 컬럼명 (fieldName)
        // ex) _gridHelper.changeCheckState("chk_include", true);
        changeCheckState: function(p_ColumnName, p_CheckState) {
            p_CheckState = typeof(p_CheckState) != 'boolean' ? true : p_CheckState;

            const api = this.__gridOption.api;
            if(this.getAllGridData().length < 1) {
                if(typeof(notifyDanger) == "function") {
                    notifyDanger("조회된 데이터가 없습니다.");
                } else {
                    alert("조회된 데이터가 없습니다.");
                }
            } else {
            	api.forEachNode( function(rowNode) {
                    (rowNode.gridApi.getModel().getRow(rowNode.rowIndex)).setDataValue(p_ColumnName, (p_CheckState ? "Y" : "N"));
                    if(typeof(rowNode.data["state_col"]) != 'undefined') {
                        rowNode.data["state_col"] = "U";
                    }
                });
            }
        },
        // changeCheckState와 기능 동일
        // state_col이 없어도 check 처리
        // 210531 min0
        setCheckState: function(p_ColumnName, p_CheckState) {
            p_CheckState = typeof(p_CheckState) != 'boolean' ? true : p_CheckState;

            const api = this.__gridOption.api;
            if(this.getAllGridData().length < 1) {
                if(typeof(notifyDanger) == "function") {
                    notifyDanger("조회된 데이터가 없습니다.");
                } else {
                    alert("조회된 데이터가 없습니다.");
                }
            } else {
            	api.forEachNode( function(rowNode) {
                	const row = rowNode.data;

					row["includeValue"] = (p_CheckState ? "Y" : "N");
					row["state_col"] = (p_CheckState ? "U" : "");
					api.applyTransaction({update: [row]});
                });
            }
        },
        onStateChangeClick: function(p_StateValue) {
            this.selectedData = this.__gridOption.api.getSelectedRows();

            if(this.selectedData.length < 1){
                alert("행이 선택되지 않았습니다.");
                return;
            }

            this.__gridOption.api.forEachNode( function(rowNode) {
                if(rowNode.selected) {
                    if(typeof(rowNode.data["state_col"]) != 'undefined') {
                        if(rowNode.data["state_col"] != "C") {
                            (rowNode.gridApi.getModel().getRow(rowNode.rowIndex)).setDataValue("state_col", p_StateValue);
                        }
                    } else {
                        rowNode.data["state_col"] = p_StateValue;
                        (rowNode.gridApi.getModel().getRow(rowNode.rowIndex)).setDataValue("state_col", p_StateValue);
                    }
                }
            });
        },
        onStateChangeClickCheck: function(p_StateValue, p_ColumnName, p_DenyValue) {
            this.selectedData = this.__gridOption.api.getSelectedRows();

            if(this.selectedData.length < 1){
                alert("행이 선택되지 않았습니다.");
                return;
            }

            var checkChangable = true;

            this.__gridOption.api.forEachNode( function(rowNode) {
                if(rowNode.selected) {
                    if(rowNode.data[p_ColumnName] == p_DenyValue) {
                        checkChangable = false;
                    } else {
                        if(typeof(rowNode.data["state_col"]) != 'undefined') {
                            if(rowNode.data["state_col"] != "C") {
                                (rowNode.gridApi.getModel().getRow(rowNode.rowIndex)).setDataValue("state_col", p_StateValue);
                            }
                        } else {
                            rowNode.data["state_col"] = p_StateValue;
                            (rowNode.gridApi.getModel().getRow(rowNode.rowIndex)).setDataValue("state_col", p_StateValue);
                        }
                    }
                }
            });

            if(!checkChangable) {
                notifyDanger("처리할 수 없는 행이 있습니다. 상태: " + lookupGubnText(p_StateValue));
            }
        },
        userDateOnlyPickerEditor: GridCustomEditor.userDateOnlyPickerEditor,
        userCheckBoxEditor: GridCustomEditor.userCheckBoxEditor,
        userRowRadioEditor: GridCustomEditor.userRowRadioEditor,
        userRadioEditor: GridCustomEditor.userRadioEditor,
        userInputBoxEditor: GridCustomEditor.userInputBoxEditor,
        SelectFloatingFilter : GridCustomFilter.getSelectFloatingFilterComponent,
        userMaskingPicker: GridCustomEditor.userMaskingEditor
    }

    // initGrid.prototype.onRemoveSelected = function(){
    //     var selectedData = __gridOption.api.getSelectedRows();
    //     var res = __gridOption.api.applyTransaction({remove: selectedData});
    //     printResult(res);
    // }

    return initGrid;
}());
