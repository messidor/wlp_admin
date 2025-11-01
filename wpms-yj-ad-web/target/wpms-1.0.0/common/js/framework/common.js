/*

    Common javascript functions

 */

//
if(typeof(String.prototype.repeat) != 'function') {
    String.prototype.repeat = function(count) {
        var str = this;
        var res = "";
        for(var i = 0; i < count; i++) {
            res += str;
        }
        return res;
    }
}

// 로딩 이미지 표시 여부 (기본값 = true)
var __g_Check_Loading_Display = true;

/**
 * 로딩 이미지 표시 여부 변경
 * @param {boolean} p_CheckLoad true:표시, false:미표시
 */
function setLoadImage(p_CheckLoad) {
    p_CheckLoad = typeof(p_CheckLoad) != 'boolean' ? false : p_CheckLoad;

    __g_Check_Loading_Display = p_CheckLoad;
}

/**
 * 객체 복사(deep clone)를 진행하며, 원래 객체를 참조하지 않도록 함 (재귀함수)
 *
 * @param {JSON} obj 복사할 객체
 *
 * @return {JSON} 복사된 객체
 */
function deepClone(obj) {
    if(obj === null || typeof obj !== 'object') {
        return obj;
    }

    const result = Array.isArray(obj) ? [] : {};

    for(let key of Object.keys(obj)) {
        result[key] = deepClone(obj[key]);
    }

    return result;
}

function getBrowser(){
    var agent = navigator.userAgent.toLowerCase();
    var returnStr = "";

    if (agent.indexOf("chrome") != -1) {
        returnStr = 1;
    }
    else if (agent.indexOf("safari") != -1) {
        returnStr = 2;
    }
    else if (agent.indexOf("firefox") != -1) {
        returnStr = 3;
    }
    else if ((navigator.appName == 'Netscape' && agent.indexOf('trident') != -1) || (agent.indexOf("msie") != -1)) {
        returnStr = 4;
    }

    return returnStr;
}

function isMobile(){
    var UserAgent = navigator.userAgent;

	if (UserAgent.match(/iPhone|iPod|Android|Windows CE|BlackBerry|Symbian|Windows Phone|webOS|Opera Mini|Opera Mobi|POLARIS|IEMobile|lgtelecom|nokia|SonyEricsson/i) != null || UserAgent.match(/LG|SAMSUNG|Samsung/) != null)
	{
		return true;
	}else{
		return false;
    }
}

function allCheckEventAdd(parentId){
    //if($("#" + divName + " > div:eq(0) checkbox").length > 0 ){
        $("#" + parentId).on("click", "div:eq(0) input#" + parentId + "__allCheck" ,function(ev) {
            // 전체 체크/해제 기능
            var v = $(this).is(":checked");
            $("#" + parentId + " tbody input[name='" + parentId + "__checkbox']").not(":disabled").prop("checked", v);
        });
    //}
}

function rowSelected(p_grid, p_obj){
    var trIdx = p_obj.index();

    $("#" + p_grid + " tbody tr").each(function(idx, elem){
        var tr_class = idx % 2 == 1 ? "table-secondary" : "";

        if(typeof($(elem).attr("data-__empty")) == "undefined") {
            $(elem).removeClass("table-secondary").addClass(tr_class);

            if($(elem).index() == trIdx){

                    $(elem).removeClass("table-secondary").addClass("table-tr-selected");
            }
            else{
                $(elem).removeClass("table-tr-selected");
            }
        }
    });
}

function initDateOne(p_dateObj_id, p_setDate){
    var _setDate = p_setDate || DateToStr(new Date(),"-");

    if((p_dateObj_id || "") != ""){

        $("#" + p_dateObj_id).datepicker({
            format: "yyyy-mm-dd",
            autoclose: true,
            keepOpen: false
        }).datepicker("setDate", _setDate);
    }
}

function initDate(p_dateObj1_id, p_dateObj2_id, p_setDateF, p_setDateT, p_today, p_week, p_month){
    var today = p_today || "";
    var week = p_week || "";
    var month = p_month || "";

    if((p_dateObj1_id || "") != "" && (p_dateObj2_id || "")){

        $("#" + p_dateObj1_id +", #" + p_dateObj2_id).datepicker({
            format: "yyyy-mm-dd",
            autoclose: true,
            keepOpen: false
        }).datepicker("setDate", p_setDateF);

        $("#" + p_dateObj2_id).datepicker("setDate", p_setDateT);

        if(today != ""){
            // 오늘
            $("#" + today).click(function() {
                $("#" + p_dateObj1_id).datepicker("setDate", today);
                $("#" + p_dateObj2_id).datepicker("setDate", today);
            });
        }

        if(week != ""){
            // 1주일
            $("#" + week).click(function() {

                var weekDiff = new Date();
                weekDiff.setDate(weekDiff.getDate() - 6);

                $("#" + p_dateObj1_id).datepicker("setDate", weekDiff);
                $("#" + p_dateObj2_id).datepicker("setDate", today);
            });
        }

        if(month != ""){
            // 한달
            $("#" + month).click(function() {

                var monthDiff = new Date();
                monthDiff.setMonth(monthDiff.getMonth() - 1);

                $("#" + p_dateObj1_id).datepicker("setDate", monthDiff);
                $("#" + p_dateObj2_id).datepicker("setDate", today);
            });
        }
    }
}

function rangeDatePickerLocaleSetting(p_UseTimePicker, p_OtherDateFormat, p_OtherTimeFormat) {

    p_UseTimePicker = typeof(p_UseTimePicker) == 'boolean' ? p_UseTimePicker : false;

    p_OtherDateFormat = p_OtherDateFormat || "YYYY-MM-DD";
    p_OtherTimeFormat = p_OtherTimeFormat || "HH:mm";

    return {
        "format": p_OtherDateFormat + (p_UseTimePicker ? " " + p_OtherTimeFormat : ""),
        "applyLabel": "적용",
        "cancelLabel": "취소",
        "fromLabel": "시작",
        "toLabel": "종료",
        "customRangeLabel": "Custom",
        "weekLabel": "주",
        "daysOfWeek": [
            "일",
            "월",
            "화",
            "수",
            "목",
            "금",
            "토"
        ],
        "monthNames": [
            "1월",
            "2월",
            "3월",
            "4월",
            "5월",
            "6월",
            "7월",
            "8월",
            "9월",
            "10월",
            "11월",
            "12월"
        ],
        "firstDay": 0,
        "cancelLabel": "닫기"
    };
}

/*
    Name            : function OpenPopup
    Parameters      : url - URL
                      winName - 팝업창의 이름
                      szX - 세로 크기(px)
                      szY - 가로 크기(px)
                      isCenter - true(중앙), false(좌상단)
                      isScroll - true(스크롤 가능), false(스크롤 불가)
                      isResizable - true(크기조정가능), false(크기조정불가)
*/
function OpenPopup(url, winName, szX, szY, isCenter, isScroll, isResizable) {

    var scrollable = "0", resizable = "0"
    var winLeft = "20", winTop = "20";
    var popSetting = "";

    if (isCenter == true) {
        winLeft = (screen.availWidth - szY) / 2;
        winTop = (screen.availHeight - szX) / 2;
    }

    if (isScroll == true) {
        scrollable = "1";
    }

    if (isResizable == true) {
        resizable = "1";
    }

    popSetting = "left=" + winLeft + ",top=" + winTop + ",fullscreen=0,toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=" + scrollable + ",resizable=" + resizable + ",width=" + szY + ",height=" + szX + "";

    return window.open(url, winName, popSetting);

};

// 한번 열어놓았던 팝업을 계속 이용하도록 처리
// url, 가로크기(px), 세로크기(px)
// , 팝업 창의 고유 코드를 위한 추가 문자열 (선택)
function OpenPopupSingle(url, szY, szX, sepStr) {
    var retObj;
    sepStr = sepStr || "";
    retObj = OpenPopup("/walletfree-admin" + url, "___OpenFixedPopup" + sepStr, szX, szY, false, true, false);
    return retObj;
}

// 한번 열어놓았던 팝업은 그냥 두고 무조건 새로 창을 열도록 처리
// url, 가로크기(px), 세로크기(px)
function OpenPopupMulti(url, szY, szX) {
    return OpenPopup(url, "", szX, szY, false, true, false);
}

// JSON 배열을 URL Parameter 로 만들어줌.
// 단, [] 배열이 없어야 함.
function getSerializedFromJSON(p_JSON) {
    var res = "";

    for(var key in p_JSON) {
        res += ((res.length < 1) ? "" : "&") + key + "=" + p_JSON[key];
    }

    return res;
}

/*
    Function Name       : CheckJQueryEventIsNumericOrSpecialKeys
    Does                : 숫자 또는 특정 키가 눌렸는지 확인하는 함수
    Parameters          : jQuery의 이벤트 객체 (없으면 false가 항상 반환)
    Returns             : 눌렸다면 true, 아니면 false

    Example)

        Source :

            $(".jQueryNumericAllow").keydown(function (ev) {
                if (!CheckJQueryEventIsNumericOrSpecialKeys(ev)) {
                    ev.preventDefault();
                    return false;
                }
            });

        Description for Source :

            class="jQueryNumericAllow" 인 태그에서 키가 눌려졌을 때
            이 함수(CheckJQueryEventIsNumericOrSpecialKeys)를 통해 숫자 입력 여부를 체크하고
            숫자이거나 허용된 문자이면 넘어가되,
            그렇지 않으면 입력 자체를 취소하는(ev.preventDefault(); return false;) 소스.
*/
function CheckJQueryEventIsNumericOrSpecialKeys(ev) {
    // 파라미터가 없으면 false를 넘긴다.
    if (typeof (ev) != 'undefined') {
        // keyCode 속성이 없으면 false를 넘긴다.
        if (typeof (ev.keyCode) != 'undefined') {
            return (ev.keyCode >= 48 && ev.keyCode <= 57) ||   // 숫자
                    (ev.keyCode >= 96 && ev.keyCode <= 105) ||  // 넘버패드 숫자
                    (ev.keyCode == 9) ||                        // 탭
                    (ev.keyCode == 8) ||                        // backspace
                    (ev.keyCode == 16) ||                       // shift
                    (ev.keyCode >= 33 && ev.keyCode <= 40) ||   // 화살표, page up, page down, end, home
                    (ev.keyCode == 45) ||                       // insert
                    (ev.keyCode == 46) ||                       // delete
                    (ev.keyCode == 190) ||                      // .
                    (ev.keyCode == 189) ||                      // -
                    (ev.keyCode == 109) ||                      // -
                    (ev.keyCode == 13);                         // 엔터
        } else {
            return false;
        }
    } else {
        return false;
    }
}

function CheckJQueryEventIsNumericOrSpecialKeys2(ev) {
    // 파라미터가 없으면 false를 넘긴다.
    if (typeof (ev) != 'undefined') {
        // keyCode 속성이 없으면 false를 넘긴다.
        if (typeof (ev.keyCode) != 'undefined') {
            return (ev.keyCode >= 48 && ev.keyCode <= 57) ||   // 숫자
                    (ev.keyCode >= 96 && ev.keyCode <= 105) ||  // 넘버패드 숫자
                    (ev.keyCode == 9) ||                        // 탭
                    (ev.keyCode == 8) ||                        // backspace
                    (ev.keyCode == 16) ||                       // shift
                    (ev.keyCode >= 33 && ev.keyCode <= 40) ||   // 화살표, page up, page down, end, home
                    (ev.keyCode == 45) ||                       // insert
                    (ev.keyCode == 46) ||                       // delete
                    (ev.keyCode == 190) ||                      // .
                    (ev.keyCode == 189) ||                      // -
                    (ev.keyCode == 109) ||                      // -
                    (ev.keyCode == 13);                         // 엔터
        } else {
            return false;
        }
    } else {
        return false;
    }
}

// 숫자, 영문자, 대시(-), 언더바(_) 만 처리
function CheckJQueryEventIsNumericOrSpecialKeys3(ev) {
    // 파라미터가 없으면 false를 넘긴다.
    if (typeof (ev) != 'undefined') {
        // keyCode 속성이 없으면 false를 넘긴다.
        if (typeof (ev.keyCode) != 'undefined') {
            return (ev.keyCode >= 48 && ev.keyCode <= 57) ||   // 숫자
                    (ev.keyCode >= 96 && ev.keyCode <= 105) ||  // 넘버패드 숫자
                    (ev.keyCode >= 65 && ev.keyCode <= 90) ||   // 영문자
                    (ev.keyCode == 9) ||                        // 탭
                    (ev.keyCode == 8) ||                        // backspace
                    (ev.keyCode == 16) ||                       // shift
                    (ev.keyCode >= 33 && ev.keyCode <= 40) ||   // 화살표, page up, page down, end, home
                    (ev.keyCode == 45) ||                       // insert
                    (ev.keyCode == 46) ||                       // delete
                    (ev.keyCode == 189) ||                      // -
                    (ev.keyCode == 109) ||                      // -
                    (ev.keyCode == 13);                         // 엔터
        } else {
            return false;
        }
    } else {
        return false;
    }
}

// 숫자가 아닌 것을 없애고 숫자만 남김 (콤마도 없앰)
function ReplaceNonNumericString(str) {

    // 아무 문자도 없다면 "" 이라고 세팅해 줌
    if (str.length <= 0) {
        return "";
    }

    // 숫자가 아닌 것을 찾는다.
    var res = str.match(/[^0-9.-]/gi);

    // 있다면 그 숫자가 아닌 것들을 없애고 그 결과를 화면에 표시한다.
    if (res != null) {
        str = str.replace(/[^0-9.-]/gi, "");
        //str = str.substring(0, str.indexOf(".") + 1) + str.substring(str.indexOf(".") + 1, str.length).replace(/\D/gi, "");
        return str;
    } else {
        return str;
    }
}

// 숫자가 아닌 것을 없애고 숫자만 남김
// jQueryNumericInputCheck2 클래스를 위한 처리
function ReplaceNonNumericString2(str) {

    // 아무 문자도 없다면 "0" 이라고 세팅해 줌
    if (str.length <= 0) {
        return "";
    }

    // 숫자가 아닌 것을 찾는다.
    var res = str.match(/[^0-9]/gi);

    // 있다면 그 숫자가 아닌 것들을 없애고 그 결과를 화면에 표시한다.
    if (res != null) {
        str = str.replace(/[^0-9]/gi, "");
        //str = str.substring(0, str.indexOf(".") + 1) + str.substring(str.indexOf(".") + 1, str.length).replace(/\D/gi, "");
        return str;
    } else {
        return str;
    }
}

// 숫자가 아닌 것을 없애고 숫자만 남김 (콤마도 없앰)
function ReplaceNonAlphaNumericString(str) {

    // 아무 문자도 없다면 "0" 이라고 세팅해 줌
    if (str.length <= 0) {
        return "";
    }

    // 숫자가 아닌 것을 찾는다.
    var res = str.match(/[^0-9A-Za-z_-]/g);

    // 있다면 그 숫자가 아닌 것들을 없애고 그 결과를 화면에 표시한다.
    if (res != null) {
        str = str.replace(/[^0-9A-Za-z_-]/g, "");
        return str;
    } else {
        return str;
    }
}

// 숫자에 콤마 붙이기 (소수점 안됨)
function addCommaDecimal(v) {

    var sv = v + "";

    var objRegExp = new RegExp('(-?[0-9]+)([0-9]{3})');
    while (objRegExp.test(sv)) {
        sv = sv.replace(objRegExp, '$1,$2');
    }
    return sv;
}

// 숫자에 콤마 붙이기 (소수점 처리, addCommaDecimal 함수 이용함)
// 값, 0일 때 표시 여부 (0표시 혹은 빈값), 소수점 자리수
function addCommas(v, p_ZeroHide, p_Decimal) {

    p_ZeroHide = typeof(p_ZeroHide) != 'undefined' ? p_ZeroHide : true;
    p_Decimal = typeof(p_Decimal) != 'undefined' ? p_Decimal : -1;

    if(v == "")
        return "";

    v = (v + "").replace(/,/gi, "");

    v = parseFloat(v);

    v = isNaN(v) ? 0 : v;

    var sv = v + "";

    if(v == 0) {
        // 숫자로 바꿔서 0인 경우 (0.00, 0 같은 것으로 침)
        // 소수점 자리수가 있으면 표시, 없으면 그냥 0만 리턴함
        // 단, 0을 숨겨야 하는 경우에는 빈값으로 리턴함
        return p_ZeroHide ? "" : ("0" + ((p_Decimal > 0 ? "." + "0".repeat(p_Decimal) : "0".repeat(p_Decimal))));
    }

    if(sv.indexOf(".") > -1) {
        var v1 = sv.substring(0, sv.indexOf("."));
        var v2 = sv.substr(sv.indexOf(".") + 1);
        var dec = v2 + (p_Decimal - v2.length > 0 ? ("0".repeat(p_Decimal - v2.length)) : ""); // 소수부

        return addCommaDecimal(v1) + (dec.length > 0 ? "." + dec : dec);
    } else {
        return addCommaDecimal(v) + (p_Decimal > 0 ? ("." + "0".repeat(p_Decimal)) : "");
    }
}

// 텍스트박스 세팅되어 있는 곳에 콤마 처리 하는 함수
function setNumericComma() {
    if($("input[type='text'].jQueryNumericInputCheck").length > 0) {
        $("input[type='text'].jQueryNumericInputCheck").each(function(idx, elem) {
            if($(elem).prop("readonly") == true) {
                return true;
            }
            // 포커스 out 했을 때에 해당 값에 콤마를 찍어줌.
            $(elem).val(addCommas($(elem).val()));
        });
    }
}

// 텍스트박스 세팅되어 있는 곳에 콤마 처리 하는 함수 (단 빈값은 그대로 두도록 함)
// jQueryNumericInputCheck2 클래스를 위한 처리
function setNumericComma2() {
    if($("input[type='text'].jQueryNumericInputCheck2").length > 0) {
        $("input[type='text'].jQueryNumericInputCheck2").each(function(idx, elem) {
            if($(elem).prop("readonly") == true) {
                return true;
            }
            // 포커스 out 했을 때에 해당 값에 콤마를 찍어줌.
            //$(elem).val(addCommas($(elem).val()));
        });
    }
}

// 중단 내용 크기 컨트롤
function resizeFixedContents() {
    var menu_height = $("#menu_all_wrapper").height();
    var bottom_height = $("#bottom_copyright").height();

    var window_height = $(window).height();
    var html_height = $("html").height();

    if(html_height < window_height) {
        $(".fix-contents-area").height(window_height - menu_height - bottom_height - 22);
    } else {
        $(".fix-contents-area").css("height", "");
    }
}

// Javascript lpad, rpad ( oracle lpad, rpad 와 동일)
/*
*  originalstr: lpad 할 text
* length: lpad할 길이
* strToPad: lpad 시킬 text
*/


function lpad(originalstr, length, strToPad) {

    while (originalstr.length < length)
        originalstr = strToPad + originalstr;
    return originalstr;

}

/*
*  originalstr: rpad 할 text
* length: rpad할 길이
* strToPad: rpad 시킬 text
*/

function rpad(originalstr, length, strToPad) {

    while (originalstr.length < length)
        originalstr = originalstr + strToPad;
    return originalstr;

}

// =================================================
// 주별 더하기/빼기
// =================================================
function addWeek(strdate, weeks) {
    var date = new Date(strdate);
    date.setDate(date.getDate() + weeks * 7);
    return DateToStr(date);
}

// =================================================
// 일별 더하기/빼기
// =================================================
function addDay(strdate, days, seperator) {
    seperator = seperator || "";
    var date = new Date(strdate);
    date.setDate(date.getDate() + days);
    return DateToStr(date, seperator);
}

// =================================================
// Date 형을 String 형태(yyyy-MM-dd)로 변환 date(20180101) -> 2018-01-01 new Date()
// =================================================
function DateToStr(date, seperator) {
    seperator = seperator || "";
    return date.getFullYear() + seperator + AddZero(eval(date.getMonth() + 1)) + seperator + AddZero(date.getDate());
}

// =================================================
// Date 형을 String 형태(yyyy-MM-dd)로 변환 str(20180101) -> 20180101
// =================================================
function StringToDate(strDate, seperator) {
    seperator = seperator || "";
    if (strDate && strDate.indexOf(seperator) == -1) {
    	strDate = strDate.substr(0, 4) + seperator + strDate.substr(4, 2) + seperator + strDate.substr(6, 2);
    }
    return strDate ? strDate : "";
}

// =================================================
// 2자리수 설정
// =================================================
function AddZero(num) {
    return (num < 10 ? "0" : "") + num;
}

var g_StackLoadingImageStatus = 0;
var g_ShowResultMessageFlag = false;

function changeLoadingMessage(p_Message) {
    $("body > .theme-loader .loader-track .disp-percent").text(p_Message);
}

// 로딩 이미지 보여주거나 숨기기 (true 보여주기, false 숨겨주기)
function changeLoadingImageStatus(p_IsShow) {

    // 로딩 이미지를 표시해야 하는 경우에만 표시하도록 수정함
    if(__g_Check_Loading_Display) {

        if(p_IsShow == true) {
            if(g_StackLoadingImageStatus > 0) {
                ++g_StackLoadingImageStatus;
                //console.log("p_IsShow::" + p_IsShow + "   g_StackLoadingImageStatus::::" + g_StackLoadingImageStatus);
            } else {
                $(".theme-loader").css({
                    "display" : "block"
                });
                ++g_StackLoadingImageStatus;
                //console.log("p_IsShow::" + p_IsShow + "   g_StackLoadingImageStatus::::" + g_StackLoadingImageStatus);
            }
        } else {
            if(g_StackLoadingImageStatus > 0) {
                --g_StackLoadingImageStatus;
                //console.log("p_IsShow::" + p_IsShow + "   g_StackLoadingImageStatus::::" + g_StackLoadingImageStatus);
                if(g_StackLoadingImageStatus <= 0){
                    $(".theme-loader").css({
                        "display" : "none"
                    });
                    g_ShowResultMessageFlag = true;
                    g_StackLoadingImageStatus = 0;
                }
            } else {
                $(".theme-loader").css({
                    "display" : "none"
                });
                g_StackLoadingImageStatus = 0;
                //console.log("p_IsShow::" + p_IsShow + "   g_StackLoadingImageStatus::::" + g_StackLoadingImageStatus);
            }
        }

    }
}

// alert 창 대신 사용할 수 있는 버전
function alertModal(p_Title, p_Contents) {
    if($("#alertModal").length < 1) {
        alert(p_Contents);
    } else {
        $("#alertModal").find(".modal-title").text(p_Title);
        $("#alertModal").find(".modal-body p").html(p_Contents);
        $("#alertModal").modal("show");
    }
}

function gridContentHeightMax(){
    var window_height = $(window).height();

    var menu_all_wrapper_height = $("#menu_all_wrapper").height();

    var grid_header = 131;
    var grid_paging = 36;
    var bottom_margin = 5;
    var return_height = 0;

    var gap_height = 20;

    if(getBrowser() == "4"){
        //ie
        grid_header = 134;
        grid_paging = 37;
    }

    return_height = window_height - menu_all_wrapper_height - grid_header - grid_paging - bottom_margin - gap_height;

    if(isMobile()){
        return_height = 300;
    }

    return return_height;
}

function gridContentHeight(){
    var search_height = 0;
    var wrap = $("div.page-wrapper");

    if(wrap.length < 1) {
    	wrap = $("div.top");
    	if(wrap.length < 1) {
    		return;
    	}
    	search_height += 10;
    }

    if($("#search_all_wrapper").length < 1) {
        return;
    }

    $("div[data-search-area]").each(function(idx, elem){
        search_height = 30 + Number(search_height + $(elem).css("height").replace("px","")) + Number($(elem).css("margin-top").replace("px","")) + Number($(elem).css("margin-bottom").replace("px",""));
    });

    var window_height = $(window).height();
    var fix_contents_area = $(".fix-contents-area").height();
    var menu_all_wrapper_height = $("#menu_all_wrapper").height();
    //var menu_all_wrapper_height = 0;
    //var div_title_text_height = Number($("div.div-title-text").css("height").replace("px","")) + Number($("div.div-title-text").css("margin-top").replace("px","")) + Number($("div.div-title-text").css("margin-bottom").replace("px",""));
    var head_all_wrapper_height = $("#head_all_wrapper").height();
    var search_all_wrapper_height = $("#search_all_wrapper").height() + Number($("#search_all_wrapper").css("margin-bottom").replace("px",""));
    var search_area_height = Number(wrap.css("padding-top").replace("px","")) + Number(wrap.css("padding-bottom").replace("px","")) + Number($("div.pcoded-inner-content").css("padding-top").replace("px","")) + Number($("div.pcoded-inner-content").css("padding-bottom").replace("px",""));

    var div_title_text_height = 0;
    //var search_area_height = Number($("div.search-area").css("height").replace("px","")) + Number($("div.search-area").css("margin-top").replace("px","")) + Number($("div.search-area").css("margin-bottom").replace("px",""));
    //var bottom_copyright_height = Number($("#bottom_copyright").css("height").replace("px","")) + Number($("#bottom_copyright").css("margin-top").replace("px","")) + Number($("#bottom_copyright").css("margin-bottom").replace("px",""));
    var bottom_copyright_height = 0;
    var grid_header = 70;
    var grid_paging = 36;
    var bottom_margin = 5;
    var return_height = 0;
    if(getBrowser() == "4"){
        //ie
        grid_header = 132;
        grid_paging = 37;
    }

    // console.log("window_height : " + window_height);
    // console.log("menu_all_wrapper_height : " + menu_all_wrapper_height);
    // console.log("head_all_wrapper_height : " + head_all_wrapper_height);
    // console.log("search_all_wrapper_height : " + search_all_wrapper_height);
    // console.log("search_area_height : " + search_area_height);
    // console.log("fix_contents_area : " + fix_contents_area + " div_title_text_height : " + div_title_text_height + " search_area_height : " + search_area_height + " grid_header : " + grid_header + " grid_paging : " + grid_paging + " search_height : " +  search_height + " bottom_margin : " + bottom_margin);

    // return fix_contents_area - div_title_text_height - search_area_height - grid_header - grid_paging - search_height - bottom_margin;
    return_height = window_height - menu_all_wrapper_height - head_all_wrapper_height - search_all_wrapper_height - div_title_text_height - search_area_height - grid_header - grid_paging - search_height - bottom_margin - bottom_copyright_height;

    if(isMobile()){
        return_height = 300;
    }

    return return_height;
}

// 날짜형식인지 체크 (NaN 이 아니고 Date 형식인 경우 날짜 형식으로 인정함)
// 2019-01-35 : false
// "asdfsadf" : false
function getIsDate(p_DateStr) {
    var chkDate = new Date(p_DateStr);
    return chkDate instanceof Date && !isNaN(chkDate);
}

/* 연락처 자동 처리하여 리턴하는 함수
 * p_Num : 변경할 문자열
 */
function returnPhoneNumber(p_Num) {

    if(p_Num.length > 11) {
        p_Num = p_Num.substring(0, 11);
    }

    if(p_Num.length == 11) {
        return p_Num.replace(/(\d{3})(\d{4})(\d{4})/, '$1-$2-$3');
    } else if(p_Num.length == 8) {
        return p_Num.replace(/(\d{4})(\d{4})/, '$1-$2');
    } else {
        if(p_Num.indexOf('02') == 0) {
            if(p_Num.length == 9){
                return p_Num.replace(/(\d{2})(\d{3})(\d{4})/, '$1-$2-$3');
            }else if(p_Num.length == 10){
                return p_Num.replace(/(\d{2})(\d{4})(\d{4})/, '$1-$2-$3');
            }
            return p_Num.replace(/(\d{2})(\d{4})(\d{4})/, '$1-$2-$3');
        } else {
            return p_Num.replace(/(\d{3})(\d{3})(\d{4})/, '$1-$2-$3');
        }
    }
}

/* 연락처 자동 하이픈 처리
 * obj  : $("#id")
 * type : 0             ex) 010-****-1234로 표기
 */
function inputPhoneNumber(obj, type) {
    var number = obj.val().replace(/-/g,'');
    var phone = "";

    if(number.length==11){
        if(type==0){
            phone = number.replace(/(\d{3})(\d{4})(\d{4})/, '$1-****-$3');
        }else{
            phone = number.replace(/(\d{3})(\d{4})(\d{4})/, '$1-$2-$3');
        }
    }else if(number.length==8){
        phone = number.replace(/(\d{4})(\d{4})/, '$1-$2');
    }else{
        if(number.indexOf('02')==0){
            if(type==0){
                phone = number.replace(/(\d{2})(\d{3,4})(\d{4})/, '$1-****-$3');
            }else{
                phone = number.replace(/(\d{2})(\d{3,4})(\d{4})/, '$1-$2-$3');
            }
        } else if(number.length==9){
            if(type==0){
                phone = number.replace(/(\d{2})(\d{3,4})(\d{4})/, '$1-****-$3');
            }else{
                phone = number.replace(/(\d{2})(\d{3,4})(\d{4})/, '$1-$2-$3');
            }
        } else{
            if(type==0){
                phone = number.replace(/(\d{3})(\d{3})(\d{4})/, '$1-***-$3');
            }else{
                phone = number.replace(/(\d{3})(\d{3})(\d{4})/, '$1-$2-$3');
            }
        }
    }

    obj.val(phone);

/*
    var regNumber = /^[0-9-]*$/;

    if(!regNumber.test(obj.val()))
    {
        alert("숫자만 입력해 주세요.");
        $(obj).val("");
    }
    var number = obj.val().replace(/[^0-9]/g, "");
    var phone = "";

    if(number.length < 4) {
        return number;
    } else if(number.length < 7) {
        phone += number.substr(0, 3);
        phone += "-";
        phone += number.substr(3);
    } else if(number.length < 11) {
        phone += number.substr(0, 3);
        phone += "-";
        phone += number.substr(3, 3);
        phone += "-";
        phone += number.substr(6);
    } else {
        phone += number.substr(0, 3);
        phone += "-";
        phone += number.substr(3, 4);
        phone += "-";
        phone += number.substr(7);
    }
    obj.val(phone);
*/
}

// 이미지 미리보기 기능
function imageView(getId, input){
    if (input.files && input.files[0]) {
        var reader = new FileReader();
        reader.onload = function(e) {
            $('#' + getId).attr('src', e.target.result);
        }
        reader.readAsDataURL(input.files[0]);
    }
}

function notifyDefault(msg){
    notify("&nbsp;"+ msg, "fas fa-check", "default" );
}

function notifyPrimary(msg){
    notify("&nbsp;"+ msg, "fas fa-check", "primary" );
}

function notifyInfo(msg){
    notify("&nbsp;"+ msg, "fas fa-check", "info" );
}

function notifySuccess(msg){
    notify("&nbsp;"+ msg, "fas fa-check", "success" );
}

function notifyWarning(msg){
    notify("&nbsp;"+ msg, "fas fa-exclamation-triangle", "warning" );
}

function notifyDanger(msg){
    notify("&nbsp;"+ msg, "fas fa-exclamation-triangle", "danger" );
}

function notify(msg, icon, type){
    var title = "";
    var from = "bottom";
    var align = "left";
    var animIn = "animated bounceIn";
    var animOut = "animated bounceOut";

    //$("[data-growl]").remove();

    $.growl({
        icon: icon,
        title: title,
        message: msg,
        url: ''
    },{
        element: 'body',
        type: type,
        allow_dismiss: true,
        placement: {
            from: from,
            align: align
        },
        offset: {
            x: 30,
            y: 30
        },
        spacing: 10,
        z_index: 999999,
        delay: 2500,
        timer: 3500,
        url_target: '_blank',
        mouse_over: false,
        animate: {
            enter: animIn,
            exit: animOut
        },
        icon_type: 'class',
        template: '<div data-growl="container" class="alert" role="alert">' +
        '<button type="button" class="close" data-growl="dismiss">' +
        '<span aria-hidden="true">&times;</span>' +
        '<span class="sr-only">Close</span>' +
        '</button>' +
        '<span data-growl="icon"></span>' +
        '<span data-growl="title"></span>' +
        '<span data-growl="message"></span>' +
        '<a href="#" data-growl="url"></a>' +
        '</div>'
    });
};

// POST 방식으로 다른 페이지로 이동 처리함
// 직접 파라미터를 넣는 경우 이 함수를 사용함
function hrefPost(_url, _params) {
    var frmId = "hrefPost_" + Math.round(Math.random() * 1000000, 0);
    $("body").append('<form id="' + frmId + '" method="POST" action="' + _url + '"></form>');
    $("#" + frmId).append('<input type="hidden" name="_token" value="' + $("meta[name='csrf-token']").attr("content") + '" />');
    for(var key in _params) {
        $("#" + frmId).append('<input type="hidden" name="' + key + '" value="' + _params[key] + '" />');
    }
    $("#" + frmId).submit();
}

// 다음 API 주소 검색 및 클릭하는 작은 팝업창 객체
var element_wrap = "";

// 다음API 주소 가져오는 부분
// 파라미터 :
// 1) 주소 검색할 창이 표시될 div id
// 2) 기본 주소를 넣을 input id (영주시 ~구 ~로 1)
// 3) 추가 주소를 넣을 input id (~~아파트 등..)
function SetDaumPostCode(wrapid, addr1, addr2) {

    var addr1_position = getTagPosition($("#" + addr1)[0]);

    // wrap 를 추가하기 위한 문자열
    var wrap_html = '<div id="' + wrapid + '" style="display:none;border:1px solid;width:440px;height:300px;position:absolute;z-index:30000;left:' + (addr1_position.x + 3) + 'px;top:' + (addr1_position.y + 35) + 'px">' +
                    '<img src="//t1.daumcdn.net/postcode/resource/images/close.png" id="btnFoldWrap_' + wrapid + '" style="cursor:pointer;position:absolute;right:0px;top:-1px;z-index:1" alt="접기 버튼">' +
                    '</div>';

    element_wrap = document.getElementById(wrapid);

    if(element_wrap == null) {
        //$("#" + addr1).after(wrap_html);
        $("html").append(wrap_html);
        element_wrap = document.getElementById(wrapid);
    }

    // 주소창 두 군데와 wrapper 에 wrapper id 와 사용 중인 주소창의 id 를 넣음
    $("#" + addr1).add("#" + addr2).add("#" + wrapid).attr("data-wrapper", wrapid).attr("data-addr1", addr1).attr("data-addr2", addr2);

    // 주소 입력창 열기
    $("#" + addr1).focusin(function() {
        InitDaumPostCode(element_wrap, addr1, addr2);
        element_wrap.style.display = "block";
    });

    // 주소 입력창 닫기
    $("#btnFoldWrap_" + wrapid).click(function() {
        CloseDaumPostCode(wrapid);
    });

    // // 주소 입력창, inputbox 이외의 다른 객체 클릭시 다음 주소 입력창 닫아주기
    // $("body *").not("#" + wrapid + ",#" + addr1).click(function(ev) {
    //     ev.stopImmediatePropagation();
    //     if($(this).find("#" + addr1).length < 1) {
    //         CloseDaumPostCode(wrapid);
    //     }
    // });

    InitDaumPostCode(element_wrap, addr1, addr2);

    // element_wrap.style.display = 'block';
}

// 다음 주소 검색창을 닫아준다
function CloseDaumPostCode(wrapid) {
    if($("#" + wrapid).length > 0) {
        $("#" + wrapid).css("display", "none");
    }
}

// 다음 주소창을 사용/미사용 처리한다.
function UseDaumPostCode(p_WrapId, p_UseYN, p_Addr1, p_Addr2) {
    if(p_UseYN) {
        if($("#" + p_WrapId).length > 0) {
            // 한 번이라도 다음 주소창을 초기화 한 적이 있는 경우
            p_Addr1 = $("[data-wrapper='" + p_WrapId + "']").attr("data-addr1");
            p_Addr2 = $("[data-wrapper='" + p_WrapId + "']").attr("data-addr2");
        } else {
            // 한번도 다음 주소창을 초기화 한 적이 없는 경우 그냥 초기화 함
            // 단, 주소1, 주소2 파라미터가 있어야 함
            if(typeof(p_Addr1) == 'undefined' || typeof(p_Addr2) == 'undefined') {
                throw "Daum Postcode 를 초기화 하기 위한 주소1, 주소2 파라미터가 없습니다.";
            }
        }

        SetDaumPostCode(p_WrapId, p_Addr1, p_Addr2);
    } else {
        CloseDaumPostCode(p_WrapId);
        $("#" + $("[data-wrapper='" + p_WrapId + "']").attr("data-addr1")).off();
    }
}

// 다음 주소창 초기화
function InitDaumPostCode(_wrapObj, addr1, addr2) {

    var oId1 = addr1;
    var oId2 = typeof(addr2) != 'undefined' ? addr2 : addr1;

    var currentScroll = Math.max(document.body.scrollTop, document.documentElement.scrollTop);
    new daum.Postcode({
        maxSuggestItems: 7,
        zonecodeOnly: true,
        oncomplete: function(data) {
            // 팝업에서 검색결과 항목을 클릭했을때 실행할 코드를 작성하는 부분.

            // 각 주소의 노출 규칙에 따라 주소를 조합한다.
            // 내려오는 변수가 값이 없는 경우엔 공백('')값을 가지므로, 이를 참고하여 분기 한다.

            var fullAddr = ''; // 최종 주소 변수
            var extraAddr = ''; // 조합형 주소 변수

            // // 사용자가 선택한 주소 타입에 따라 해당 주소 값을 가져온다.
            // if (data.userSelectedType === 'R') { // 사용자가 도로명 주소를 선택했을 경우
            fullAddr = data.roadAddress == "" ? data.autoRoadAddress : data.roadAddress;

            // 사용자가 선택한 주소가 도로명 타입일때 조합한다.
            if(data.userSelectedType === 'R') {
                //법정동명이 있을 경우 추가한다.
                if(data.bname !== '') {
                    extraAddr += data.bname;
                }
                // 건물명이 있을 경우 추가한다.
                if(data.buildingName !== '') {
                    extraAddr += (extraAddr !== '' ? ', ' + data.buildingName : data.buildingName);
                }
                // 조합형주소의 유무에 따라 양쪽에 괄호를 추가하여 최종 주소를 만든다.
                fullAddr += (extraAddr !== '' ? ' ('+ extraAddr +')' : '');
            }

            // 우편번호와 주소 정보를 해당 필드에 넣는다.
            // document.getElementById('btnMapData').value = data.zonecode; //5자리 새우편번호 사용
            document.getElementById(oId1).value = fullAddr;
            document.getElementById(oId1).className += " fill";

            // iframe을 넣은 element를 우선적으로 안보이게 한다.
            // (autoClose:false 기능을 이용한다면, 아래 코드를 제거해야 화면에서 사라지지 않는다.)
            _wrapObj.style.display = 'none';

            // 우편번호 찾기 화면이 보이기 이전으로 scroll 위치를 되돌린다.
            document.body.scrollTop = currentScroll;

            // 커서를 상세주소 필드로 이동한다.
            document.getElementById(oId2).focus();
        },
        // 우편번호 찾기 화면 크기가 조정되었을때 실행할 코드를 작성하는 부분. iframe을 넣은 element의 높이값을 조정한다.
        onresize : function(size) {
            //_wrapObj.style.height = size.height+'px';
        },
        width : '100%',
        height : '100%'
    }).embed(_wrapObj);
}

// data-height 속성이 있는 객체의 높이를 조절하는 함수
function setDataHeight() {

    var calcHeight = gridContentHeight();

    $("[data-height]").each(function(idx, elem) {
        if(typeof($(elem).attr("data-height")) != "undefined"){
            if($(elem).attr("data-height").indexOf("px") > -1){
                $(elem).height($(elem).attr("data-height").replace("px",""));
            }
            else if($(elem).attr("data-height").indexOf("%") > -1){
                $(elem).height(calcHeight * (Number($(elem).attr("data-height").replace("%","")) / 100));
            }
        }
        else{
            $(elem).height(calcHeight);
        }
    });
}


// // 신규 컴포넌트 라벨 변경
// $.fn.changeLabel = function(p_labelName){
//     var obj = $(this);
//     obj.nextAll("label").text(p_labelName);
// }

/**
 * 문자열값을 넣어서 포맷팅 된 값을 리턴해 줌
 *
 * @param {String} p_Type 포맷팅 할 종류 (zip, number, phone 등 inputMasking 에 사용하는 종류를 그대로 사용함)
 * @param {String} p_Value 포맷팅 할 값
 */
function getFormatValue(p_Type, p_Value) {

    var res = p_Value;
    var maskObject;

    switch(p_Type) {
        case "zip":
            maskObject = IMask.createMask({
                mask: [{
                    mask: "00000"
                }, {
                    mask: "000-000"
                }]
            });
            res = maskObject.resolve(p_Value);
            break;
        case "number": // 일반 숫자
            res = addCommas(p_Value);
            break;
        case "phone": // 전화번호
            res = returnPhoneNumber(p_Value);
            break;
        case "saupja": // 사업자 등록번호
            maskObject = IMask.createMask({
                mask: "000-00-00000"
            });
            res = maskObject.resolve(p_Value);
            break;
        case "time": // 시:분 형태의 문자열
            maskObject = IMask.createMask({
                mask: "00:00"
            });
            res = maskObject.resolve(p_Value);
            break;
        case "time2": // 시:분:초 형태의 문자열
            maskObject = IMask.createMask({
                mask: "00:00:00"
            });
            res = maskObject.resolve(p_Value);
            break;
        case "date": // 년-월-일 형태의 문자열
            maskObject = IMask.createMask({
                mask: "0000-00-00"
            });
            res = maskObject.resolve(p_Value);
            break;
        case "date2": // 년-월 형태의 문자열
            maskObject = IMask.createMask({
                mask: "0000-00"
            });
            res = maskObject.resolve(p_Value);
            break;
        case "datetime": // 년-월-일 시:분:초 형태의 문자열
            maskObject = IMask.createMask({
                mask: "0000-00-00 00:00:00"
            });
            res = maskObject.resolve(p_Value);
            break;
    }

    return res;
}

// 해당 태그의 가로/세로 좌표를 리턴하는 함수
function getTagPosition(el) {
    // yay readability
    for (var lx=0, ly=0;
         el != null;
         lx += el.offsetLeft, ly += el.offsetTop, el = el.offsetParent);
    return {x: lx,y: ly};
}

// 여러 개의 체크박스 값을 배열로 리턴함
// 파라미터는 체크박스의 name 속성이다.
function getMultiCheckValue(p_Name) {

    var ret_val = [];

    $("input[name='" + p_Name + "']:checked").each(function(idx, elem) {
        if(!(typeof($(elem).val()) == "undefined" || $(elem).val() == "")) {
            // 체크박스에 value 값이 있고 체크되어 있는 경우
            ret_val.push($(elem).val());
        }
    });

    return ret_val;
}

//두개의 날짜를 비교하여 차이를 알려준다.
function dateDiff(_date1, _date2) {
    var diffDate_1 = _date1 instanceof Date ? _date1 :new Date(_date1);
    var diffDate_2 = _date2 instanceof Date ? _date2 :new Date(_date2);

    diffDate_1 =new Date(diffDate_1.getFullYear(), diffDate_1.getMonth()+1, diffDate_1.getDate());
    diffDate_2 =new Date(diffDate_2.getFullYear(), diffDate_2.getMonth()+1, diffDate_2.getDate());

    var diff = Math.abs(diffDate_2.getTime() - diffDate_1.getTime());
    diff = Math.ceil(diff / (1000 * 3600 * 24));

    return diff;
}

function replaceDate(date) {
	var arrDate = date.split(' - ');

	arrDate[0] = arrDate[0].replaceAll('-', '');
	arrDate[1] = arrDate[1].replaceAll('-', '');

	return arrDate;
}

/* CamelCase to UnderScoreCase  */
function reverse2CamelCase(string) {
	if (typeof string == 'number') {
		return string.toString();
	}

	return string.replace(/[A-Z]/g, function(upp, i, st) {
		return (i==0 ? '' : '_') + upp.toLowerCase();
	});
}


function noop() {}

//multiselect 만들어 줌
//1. 만들어줄 css selector (필수)
//2. 최대 높이 (기본 400)
//3. 버튼 너비 (기본 150)
//4. 미선택시 텍스트 (기본 "선택")
//5. 모두 선택 버튼의 텍스트 (기본 "전체 선택")
//6. multiselect 변경시 이벤트 함수 (option, checked, select) 를 파라미터로 받음
//7. 모두선택 버튼 사용 여부 (기본 true)
//8. 내부 검색 기능 사용 여부 (기본 true)
//9. select box 에 데이터가 없으면 선택 불가능하게 처리 할지의 여부 (기본 true)
//10. 초기화 할 시에 한 번 처리되는 함수 (select, container) 를 파라미터로 받음
function createMultiSelect(p_Selector, p_MaxHeight, p_ButtonWidth, p_NonSelectedText, p_SelectAllText, p_OnChange, p_UseSelectAll, p_UseSearch, p_DisableIfEmpty, p_InitFunc) {

	p_MaxHeight = p_MaxHeight || 400;
	p_ButtonWidth = p_ButtonWidth || 150;
	p_NonSelectedText = p_NonSelectedText || "선택";
	p_SelectAllText = p_SelectAllText || "전체 선택";
	p_OnChange = typeof p_OnChange != 'function' ? noop : p_OnChange; // noop 는 빈 function 으로 정의함
	p_UseSelectAll = typeof p_UseSelectAll != 'boolean' ? true : p_UseSelectAll;
	p_UseSearch = typeof p_UseSearch != 'boolean' ? true : p_UseSearch;
	p_DisableIfEmpty = typeof p_DisableIfEmpty != 'boolean' ? true : p_DisableIfEmpty;
	p_InitFunc = typeof p_InitFunc != 'function' ? noop : p_InitFunc;

	$(p_Selector).multiselect({
		 maxHeight: p_MaxHeight,
		 buttonWidth: p_ButtonWidth,
	     includeSelectAllOption: p_UseSelectAll,
	     enableFiltering: p_UseSearch,
	     nonSelectedText: p_NonSelectedText,
	     selectAllText: p_SelectAllText,
	     disableIfEmpty: p_DisableIfEmpty,
	     onChange: p_OnChange,
	     onInitialized: p_InitFunc,
	     selectAllName: p_Selector.replace(/[#. ]/gi, "") + '_multiselect_all',
	     buttonText: function(options, select) {
	    	 // 선택시 버튼 텍스트
	    	 if (options.length === 0) {
	             return "선택";
	         } else {
	             return options.length + " 명 선택됨";
	         }
	     },
	     checkboxName: function(option) {
	         return p_Selector.replace(/[#. ]/gi, "") + '_multiselect';
	     }
	});

	var obj = $("select.form-control").siblings(".btn-group");
	obj.children("button").addClass("form-control").css("padding", "6");
	obj.children("ul").find("label").css("color", "#37474f");
}