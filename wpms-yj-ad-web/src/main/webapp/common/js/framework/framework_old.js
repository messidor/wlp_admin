// undefined 상태를 정의함. typeof(undefined) 의 결과는 "undefined" 가 된다.
var undefined = undefined;

// startsWith 함수가 없는 경우 prototype 에 추가
String.prototype.startsWith || (String.prototype.startsWith = function(word) {
    return this.lastIndexOf(word, 0) === 0;
});

$(function() {

    // datepicker 언어 설정 (기존 영어에 한글을 덧씌움)
    // $.fn.datepicker.dates['en'] = {
    //     days: ["일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"],
    //     daysShort: ["일", "월", "화", "수", "목", "금", "토"],
    //     daysMin: ["일", "월", "화", "수", "목", "금", "토"],
    //     months: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"],
    //     monthsShort: ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"],
    //     today: "오늘",
    //     clear: "지우기",
    //     format: "yyyy-mm-dd",
    //     titleFormat: "yyyy년 mm월", /* Leverages same syntax as 'format' */
    //     weekStart: 0
    // };

    $(".fix-contents-area").css("min-height", "");

    // ajax 요청 공통 셋업
    $.ajaxSetup({
        beforeSend: function() {
            changeLoadingImageStatus(true);
        },
        complete: function() {
            //changeFixedContentsHeight();
            changeLoadingImageStatus(false);
            tableScrollSync();
        },
        error: function() {
            changeLoadingImageStatus(false);
        }
    });

    // synchronize table scroll
    tableScrollSync();

    $(window).resize(function() {
        // fixed contents control
        //changeFixedContentsHeight();

        // 투명 스크롤 컨트롤 하지 않도록 처리 (2019-02-20, 신창균)
        // - 화면 크기 변경시 투명 스크롤 컨트롤이 사라져서 그리드가 깨지는 현상 방지를 위함
        //invisibleScrollControl();
        resizeFixedContents();
    });

    // runs functions in resize event
    $(window).trigger("resize");

    $("nav#menu_all_wrapper a.dropdown-toggle").each(function() {
        $(this).trigger("click");
        $(this).blur();
    });

    $("body").on("keydown", "input[type='text'].jQueryNumericInputCheck", function(ev) {
        if($(this).prop("readonly") == true) {
            return true;
        }
        // 숫자/일부 특수키 제외하고 입력 불가능하게 함
        if (!CheckJQueryEventIsNumericOrSpecialKeys(ev)) {
            ev.preventDefault();
            return false;
        }
    }).on("keyup", "input[type='text'].jQueryNumericInputCheck", function(ev) {
        // 키를 뗐을 때 숫자 아닌 것이 있다면 없애고 없앤 결과를 화면에 표시하도록 함
        if($(this).prop("readonly") == true) {
            return true;
        }

        var v = $(this).val();

        // 아무 문자도 없다면 "0" 이라고 세팅해 줌
        if ($.trim(v).length <= 0) {
            $(this).val("");
        }

        // 숫자가 아닌 것을 찾는다.
        var res = v.match(/[^0-9.]/gi);

        // 있다면 그 숫자가 아닌 것들을 없애고 그 결과를 화면에 표시한다.
        if (res != null) {
            v = ReplaceNonNumericString(v);
            $(this).val(v);
        }
    }).on("change", "input[type='text'].jQueryNumericInputCheck", function(ev) {
        // 키를 뗐을 때 숫자 아닌 것이 있다면 없애고 없앤 결과를 화면에 표시하도록 함
        if($(this).prop("readonly") == true) {
            return true;
        }

        var v = $(this).val();

        // 아무 문자도 없다면 "0" 이라고 세팅해 줌
        if ($.trim(v).length <= 0) {
            $(this).val("");
        }

        // 숫자가 아닌 것을 찾는다.
        var res = v.match(/[^0-9.]/gi);

        // 있다면 그 숫자가 아닌 것들을 없애고 그 결과를 화면에 표시한다.
        if (res != null) {
            v = ReplaceNonNumericString(v);
            $(this).val(v);
        }
    }).on("focus", "input[type='text'].jQueryNumericInputCheck", function(ev) {
        if($(this).prop("readonly") == true) {
            return true;
        }

        var v = $(this).val();

        // 아무 문자도 없다면 "0" 이라고 세팅해 줌
        if ($.trim(v).length <= 0) {
            $(this).val("");
        }

        // 숫자가 아닌 것을 찾는다.
        var res = v.match(/[^0-9.]/gi);

        // 있다면 그 숫자가 아닌 것들을 없애고 그 결과를 화면에 표시한다.
        if (res != null) {
            v = ReplaceNonNumericString(v);
            $(this).val(v);
        }
        // 포커스 온 했을 때에 텍스트 선택
        $(this).select();
    }).on("focusout", "input[type='text'].jQueryNumericInputCheck", function(ev) {
        if($(this).prop("readonly") == true) {
            return true;
        }
        // 포커스 out 했을 때에 해당 값에 콤마를 찍어줌.
        $(this).val(addCommas($(this).val()));
    });

    ///////////////////////////////////////////////////
    $("body").on("keydown", "input[type='text'].jQueryNumericInputCheck2", function(ev) {
        if($(this).prop("readonly") == true) {
            return true;
        }
        // 숫자/일부 특수키 제외하고 입력 불가능하게 함
        if (!CheckJQueryEventIsNumericOrSpecialKeys2(ev)) {
            ev.preventDefault();
            return false;
        }
    }).on("keyup", "input[type='text'].jQueryNumericInputCheck2", function(ev) {
        // 키를 뗐을 때 숫자 아닌 것이 있다면 없애고 없앤 결과를 화면에 표시하도록 함
        if($(this).prop("readonly") == true) {
            return true;
        }

        var v = $(this).val();

        // 아무 문자도 없다면 "0" 이라고 세팅해 줌
        if ($.trim(v).length <= 0) {
            $(this).val("");
        }

        // 숫자가 아닌 것을 찾는다.
        var res = v.match(/[^0-9.]/gi);

        // 있다면 그 숫자가 아닌 것들을 없애고 그 결과를 화면에 표시한다.
        if (res != null) {
            v = ReplaceNonNumericString(v);
            $(this).val(v);
        }
    }).on("change", "input[type='text'].jQueryNumericInputCheck2", function(ev) {
        // 키를 뗐을 때 숫자 아닌 것이 있다면 없애고 없앤 결과를 화면에 표시하도록 함
        if($(this).prop("readonly") == true) {
            return true;
        }

        var v = $(this).val();

        // 아무 문자도 없다면 "0" 이라고 세팅해 줌
        if ($.trim(v).length <= 0) {
            $(this).val("");
        }

        // 숫자가 아닌 것을 찾는다.
        var res = v.match(/[^0-9.]/gi);

        // 있다면 그 숫자가 아닌 것들을 없애고 그 결과를 화면에 표시한다.
        if (res != null) {
            v = ReplaceNonNumericString(v);
            $(this).val(v);
        }
    }).on("focus", "input[type='text'].jQueryNumericInputCheck2", function(ev) {
        if($(this).prop("readonly") == true) {
            return true;
        }

        var v = $(this).val();

        // 아무 문자도 없다면 "0" 이라고 세팅해 줌
        if ($.trim(v).length <= 0) {
            $(this).val("");
        }

        // 숫자가 아닌 것을 찾는다.
        var res = v.match(/[^0-9.]/gi);

        // 있다면 그 숫자가 아닌 것들을 없애고 그 결과를 화면에 표시한다.
        if (res != null) {
            v = ReplaceNonNumericString(v);
            $(this).val(v);
        }
        // 포커스 온 했을 때에 텍스트 선택
        $(this).select();
    }).on("focusout", "input[type='text'].jQueryNumericInputCheck2", function(ev) {
        if($(this).prop("readonly") == true) {
            return true;
        }

        var v = $(this).val();
        v = parseFloat(v);
        v = isNaN(v) ? 0 : v;

        if(v == 0) {
            $(this).val("");
        }
        // 포커스 out 했을 때에 해당 값에 콤마를 찍어줌.
        //$(this).val(addCommas($(this).val()));
    });

    ///////////////////////////////////////////////////
    // 영어, 숫자, 언더바(_), 바(-) 만 처리 가능
    ///////////////////////////////////////////////////
    $("body").on("keydown", "input[type='text'].jQueryAlphaCodeInputCheck", function(ev) {
        if($(this).prop("readonly") == true) {
            return true;
        }
        // 숫자/일부 특수키 제외하고 입력 불가능하게 함
        if (!CheckJQueryEventIsNumericOrSpecialKeys3(ev)) {
            ev.preventDefault();
            return false;
        }
    }).on("keyup", "input[type='text'].jQueryAlphaCodeInputCheck", function(ev) {
        // 키를 뗐을 때 숫자 아닌 것이 있다면 없애고 없앤 결과를 화면에 표시하도록 함
        if($(this).prop("readonly") == true) {
            return true;
        }

        var v = $(this).val();

        // 아무 문자도 없다면 "0" 이라고 세팅해 줌
        if ($.trim(v).length <= 0) {
            $(this).val("");
        }

        // 숫자가 아닌 것을 찾는다.
        var res = v.match(/[^0-9A-Za-z_-]/g);

        // 있다면 그 숫자가 아닌 것들을 없애고 그 결과를 화면에 표시한다.
        if (res != null) {
            v = ReplaceNonAlphaNumericString(v);
            $(this).val(v);
        }
    }).on("change", "input[type='text'].jQueryAlphaCodeInputCheck", function(ev) {
        // 키를 뗐을 때 숫자 아닌 것이 있다면 없애고 없앤 결과를 화면에 표시하도록 함
        if($(this).prop("readonly") == true) {
            return true;
        }

        var v = $(this).val();

        // 아무 문자도 없다면 "0" 이라고 세팅해 줌
        if ($.trim(v).length <= 0) {
            $(this).val("");
        }

        // 숫자가 아닌 것을 찾는다.
        var res = v.match(/[^0-9A-Za-z_-]/g);

        // 있다면 그 숫자가 아닌 것들을 없애고 그 결과를 화면에 표시한다.
        if (res != null) {
            v = ReplaceNonAlphaNumericString(v);
            $(this).val(v);
        }
    }).on("focus", "input[type='text'].jQueryAlphaCodeInputCheck", function(ev) {
        if($(this).prop("readonly") == true) {
            return true;
        }

        var v = $(this).val();

        // 아무 문자도 없다면 "0" 이라고 세팅해 줌
        if ($.trim(v).length <= 0) {
            $(this).val("");
        }

        // 숫자가 아닌 것을 찾는다.
        var res = v.match(/[^0-9A-Za-z_-]/g);

        // 있다면 그 숫자가 아닌 것들을 없애고 그 결과를 화면에 표시한다.
        if (res != null) {
            v = ReplaceNonAlphaNumericString(v);
            $(this).val(v);
        }
        // 포커스 온 했을 때에 텍스트 선택
        $(this).select();
    }).on("focusout", "input[type='text'].jQueryAlphaCodeInputCheck", function(ev) {
        if($(this).prop("readonly") == true) {
            return true;
        }
        // 포커스 out 했을 때에 해당 값에 콤마를 찍어줌.
        //$(this).val(addCommas($(this).val()));
    });

    /// jQueryNumericInputCheck2 : 빈값은 0으로 바꾸지 않게 처리하고 jQueryNumericInputCheck 와 나머지 기능은 같음
    $("body").on("keydown", "input[type='text'].jQueryNumericInputCheck2", function(ev) {
        if($(this).prop("readonly") == true) {
            return true;
        }
        // 숫자/일부 특수키 제외하고 입력 불가능하게 함
        if (!CheckJQueryEventIsNumericOrSpecialKeys2(ev)) {
            ev.preventDefault();
            return false;
        }
    }).on("keyup", "input[type='text'].jQueryNumericInputCheck2", function(ev) {
        // 키를 뗐을 때 숫자 아닌 것이 있다면 없애고 없앤 결과를 화면에 표시하도록 함
        if($(this).prop("readonly") == true) {
            return true;
        }

        var v = $(this).val();

        // 아무 문자도 없다면 "0" 이라고 세팅해 줌
        if ($.trim(v).length <= 0) {
            $(this).val("");
            return;
        }

        // 숫자가 아닌 것을 찾는다.
        var res = v.match(/[^0-9]/gi);

        // 있다면 그 숫자가 아닌 것들을 없애고 그 결과를 화면에 표시한다.
        if (res != null) {
            v = ReplaceNonNumericString2(v);
            $(this).val(v);
        }
    }).on("change", "input[type='text'].jQueryNumericInputCheck2", function(ev) {
        // 키를 뗐을 때 숫자 아닌 것이 있다면 없애고 없앤 결과를 화면에 표시하도록 함
        if($(this).prop("readonly") == true) {
            return true;
        }

        var v = $(this).val();

        // 아무 문자도 없다면 "0" 이라고 세팅해 줌
        if ($.trim(v).length <= 0) {
            $(this).val("");
            return;
        }

        // 숫자가 아닌 것을 찾는다.
        var res = v.match(/[^0-9]/gi);

        // 있다면 그 숫자가 아닌 것들을 없애고 그 결과를 화면에 표시한다.
        if (res != null) {
            v = ReplaceNonNumericString2(v);
            $(this).val(v);
        }
    }).on("focus", "input[type='text'].jQueryNumericInputCheck2", function(ev) {
        if($(this).prop("readonly") == true) {
            return true;
        }

        var v = $(this).val();

        // 아무 문자도 없다면 "0" 이라고 세팅해 줌
        if ($.trim(v).length <= 0) {
            $(this).val("");
            return;
        }

        // 숫자가 아닌 것을 찾는다.
        var res = v.match(/[^0-9]/gi);

        // 있다면 그 숫자가 아닌 것들을 없애고 그 결과를 화면에 표시한다.
        if (res != null) {
            v = ReplaceNonNumericString2(v);
            $(this).val(v);
        }
        // 포커스 온 했을 때에 텍스트 선택
        //$(this).select();
    }).on("focusout", "input[type='text'].jQueryNumericInputCheck2", function(ev) {
        if($(this).prop("readonly") == true) {
            return true;
        }
        // 포커스 out 했을 때에 해당 값에 콤마를 찍어줌.
        //$(this).val(addCommas($(this).val()));
    });

	(function($) {

		$.fn.clickDualEvent = function(funcSingleClick, funcDblClick, sDelegateSelector, nDelay) {
			var DELAY = nDelay || 500;
			var obj = $(this);
			var selector = sDelegateSelector || "";
			var oEventTimer = null;

			if(selector == "") {
				obj.click(function(ev) {
					var innerObj = $(this);
					var clickCnt = innerObj.data("g_ClickCount");
					clickCnt = typeof(clickCnt) == "undefined" ? "0" : clickCnt;
					clickCnt = isNaN(clickCnt) ? 0 : parseInt(clickCnt, 10);

					innerObj.data("g_ClickCount", ++clickCnt);

					if(clickCnt === 1) {
						oEventTimer = setTimeout(function() {
							clickCnt = 0;
							innerObj.data("g_ClickCount", clickCnt);
							funcSingleClick.call(this, ev, innerObj);
						}, DELAY);
					} else {
						clearTimeout(oEventTimer);
						clickCnt = 0;
						innerObj.data("g_ClickCount", clickCnt);
						funcDblClick.call(this, ev, innerObj);
					}
				}).dblclick(function(ev) {
					// 시스템 이벤트 막음
					ev.preventDefault();
				});
			} else {
				obj.on("click", selector, function(ev) {
					var innerObj = $(this);
					var clickCnt = innerObj.data("g_ClickCount");
					clickCnt = typeof(clickCnt) == "undefined" ? "0" : clickCnt;
					clickCnt = isNaN(clickCnt) ? 0 : parseInt(clickCnt, 10);

					innerObj.data("g_ClickCount", ++clickCnt);

					if(clickCnt === 1) {
						oEventTimer = setTimeout(function() {
							clickCnt = 0;
							innerObj.data("g_ClickCount", clickCnt);
							funcSingleClick.call(this, ev, innerObj);
						}, DELAY);
					} else {
						clearTimeout(oEventTimer);
						clickCnt = 0;
						innerObj.data("g_ClickCount", clickCnt);
						funcDblClick.call(this, ev, innerObj);
					}
				}).on("dblclick", selector, function(ev, innerObj) {
					// 시스템 이벤트 막음
					ev.preventDefault();
				});
			}
        };

        $.fn.clickDualEventCommon = function(funcSingleClick, funcDblClick, sDelegateSelector, nDelay) {
			var DELAY = nDelay || 500;
			var obj = $(this);
			var selector = sDelegateSelector || "";
            var oEventTimer = null;



			if(selector == "") {
				obj.click(function(ev) {
					var innerObj = $(this);
					var clickCnt = innerObj.data("g_ClickCount");
					clickCnt = typeof(clickCnt) == "undefined" ? "0" : clickCnt;
					clickCnt = isNaN(clickCnt) ? 0 : parseInt(clickCnt, 10);

					innerObj.data("g_ClickCount", ++clickCnt);

					if(clickCnt === 1) {
						oEventTimer = setTimeout(function() {
							clickCnt = 0;
							innerObj.data("g_ClickCount", clickCnt);
							funcSingleClick.call(this, ev, innerObj);
						}, DELAY);
					} else {
						clearTimeout(oEventTimer);
						clickCnt = 0;
						innerObj.data("g_ClickCount", clickCnt);
						funcDblClick.call(this, ev, innerObj);
					}
				}).dblclick(function(ev) {
					// 시스템 이벤트 막음
					ev.preventDefault();
				});
			} else {
				obj.on("click", selector, function(ev) {

                    if(typeof($(this).parent().attr("data-__empty")) != "undefined") {
                        return false;
                    }

                    if($(this).children("label").children("input[name=\"" + obj.attr("id") + "__checkbox\"]").length <= 0){
                        var innerObj = $(this).parent();
                        var clickCnt = innerObj.data("g_ClickCount");
                        clickCnt = typeof(clickCnt) == "undefined" ? "0" : clickCnt;
                        clickCnt = isNaN(clickCnt) ? 0 : parseInt(clickCnt, 10);

                        innerObj.data("g_ClickCount", ++clickCnt);

                        if(clickCnt === 1) {
                            oEventTimer = setTimeout(function() {
                                clickCnt = 0;
                                innerObj.data("g_ClickCount", clickCnt);
                                funcSingleClick.call(innerObj, ev, innerObj);
                            }, DELAY);
                        } else {
                            clearTimeout(oEventTimer);
                            clickCnt = 0;
                            innerObj.data("g_ClickCount", clickCnt);
                            funcDblClick.call(innerObj, ev, innerObj);
                        }
                    }
				}).on("dblclick", selector, function(ev, innerObj) {
					// 시스템 이벤트 막음
					ev.preventDefault();
				});
			}
		};

        // 2018-12-27 colModel[].maxlength 추가
        $.fn.initGrid = function(initData){
            var obj = $(this);

            var callFunc = initData["callFunc"] || "";
            var pageId = initData["tableId"] || "";
            var colNames = initData["colNames"];
            var colModel = initData["colModel"];
            var rownNumber =initData["isNumber"] || false;
            var rowEvent =initData["rowEvent"] || "";
            var rowOrder =initData["sortName"];
            var filter =initData["filter"];
            var frozenScroll = initData["frozenScroll"] || [];
            var summation =initData["summation"];
            var rows =initData["rowNum"] || "";
            var maxRows =initData["height"] || "";
            var autoSearch =initData["isSearch"] || false;
            var editable =initData["isCheck"] || false;
            var paging = typeof(initData["isPaging"]) == "undefined" ? true : typeof(initData["isPaging"]);
            var emptyCall =initData["emptyCall"] || [{"callGubn":false, "callQueryId": ""}];
            var excel = initData["excel"] || false;
            var isScroll = typeof(initData["isScroll"]) == "undefined" ? true : initData["isScroll"];  // 기본값을 true 로 만들기 위해 사용함

            var columns_name = [];
            var columns_width = [];
            var columns_edit = [];
            var columns_visible = [];
            var columns_align = [];
            var columns_type = [];
            var columns_fomatter = [];
            var columns_formatoptions = [];
            var colSelectOption = [];
            var colGridEvent = [];
            var colSortable = [];
            var colFrozen = [];
            var colModelItem;
            var colGridEventVisible = [];
            var colSortableVisible = [];

            var columns_maxlength = [];

            var colNum = (rownNumber ? 1 : 0) + (editable ? 1 : 0);
            var hiddenCount = 0;

            for(var item in colModel) {
                colModelItem = colModel[item];

                columns_name.push(colModelItem["name"]);
                columns_width.push(colModelItem["width"]);
                columns_edit.push(colModelItem["editable"]);
                columns_visible.push(colModelItem["visible"]);
                columns_align.push(colModelItem["align"]);
                columns_type.push(colModelItem["type"] || "");
                columns_fomatter.push(colModelItem["formatter"] || "");
                columns_formatoptions.push(colModelItem["formatoptions"] || "");
                colSelectOption.push(colModelItem["selectoption"] || "");
                colGridEvent.push(colModelItem["gridEvent"] || "");
                colSortable.push(colModelItem["sortable"] || "");
                colFrozen.push(colModelItem["frozen"] || "");

                columns_maxlength.push(colModelItem["maxlength"] || "");

                if(colModelItem["visible"] == true){
                    colGridEventVisible.push(colModelItem["gridEvent"] || "");
                    colSortableVisible.push(colModelItem["sortable"] || "");
                }

                if(colModelItem["visible"]){
                    hiddenCount++;
                }
            }

            var edit_type = ["input","select","textarea"];

            for(var item in edit_type){
                var typeName = edit_type[item];

                $("#" + obj.attr("id")).on("keyup", "div:eq(1) > table > tbody > tr > td > " + typeName, function(ev) {

                    var objInput = $(this);

                    var colIdx = objInput.parent().index() - colNum;

                    if(typeof(objInput[0].tagName) != "undefined"){
                        if(editable && objInput[0].tagName.toLowerCase() == "input"){
                            objInput.parent().parent().find("input[name='" + obj.attr("id") + "__checkbox']").prop("checked", true);
                        }
                    }

                    if(colIdx > 0){
                        if(typeof(colGridEvent[colIdx]["keyup"]) != "undefined" ){
                            if(eval("typeof(" + colGridEvent[colIdx]["keyup"] + ")") == "function"){
                                eval(colGridEvent[colIdx]["keyup"] + "(objInput);");
                            }
                        }
                    }
                });

                $("#" + obj.attr("id")).on("keydown", "div:eq(1) > table > tbody > tr > td > " + typeName, function(ev) {

                    var objInput = $(this);

                    var colIdx = objInput.parent().index() - colNum;

                    if(colIdx > 0){
                        if(typeof(colGridEvent[colIdx]["keydown"]) != "undefined" ){
                            if(eval("typeof(" + colGridEvent[colIdx]["keydown"] + ")") == "function"){
                                eval(colGridEvent[colIdx]["keydown"] + "(objInput);");
                            }
                        }
                    }
                });

                $("#" + obj.attr("id")).on("focusin", "div:eq(1) > table > tbody > tr > td > " + typeName, function(ev) {

                    var objInput = $(this);

                    var colIdx = objInput.parent().index() - colNum;

                    if(colIdx > 0){
                        if(typeof(colGridEvent[colIdx]["focusin"]) != "undefined" ){
                            if(eval("typeof(" + colGridEvent[colIdx]["focusin"] + ")") == "function"){
                                eval(colGridEvent[colIdx]["focusin"] + "(objInput);");
                            }
                        }
                    }
                });

                $("#" + obj.attr("id")).on("focusout", "div:eq(1) > table > tbody > tr > td > " + typeName, function(ev) {

                    var objInput = $(this);

                    var colIdx = objInput.parent().index() - colNum;

                    if(colIdx > 0){
                        if(typeof(colGridEvent[colIdx]["focusout"]) != "undefined" ){
                            if(eval("typeof(" + colGridEvent[colIdx]["focusout"] + ")") == "function"){
                                eval(colGridEvent[colIdx]["focusout"] + "(objInput);");
                            }
                        }
                    }
                });

                $("#" + obj.attr("id")).on("click", "div:eq(1) > table > tbody > tr > td > " + typeName, function(ev) {

                    var objInput = $(this);

                    var colIdx = objInput.parent().index() - colNum;

                    if(colIdx > 0){
                        if(typeof(colGridEvent[colIdx]["click"]) != "undefined" ){
                            if(eval("typeof(" + colGridEvent[colIdx]["click"] + ")") == "function"){
                                eval(colGridEvent[colIdx]["click"] + "(objInput);");
                            }
                        }
                    }
                });

                $("#" + obj.attr("id")).on("dblclick", "div:eq(1) > table > tbody > tr > td > " + typeName, function(ev) {

                    var objInput = $(this);

                    var colIdx = objInput.parent().index() - colNum;

                    if(colIdx > 0){
                        if(typeof(colGridEvent[colIdx]["dblclick"]) != "undefined" ){
                            if(eval("typeof(" + colGridEvent[colIdx]["dblclick"] + ")") == "function"){
                                eval(colGridEvent[colIdx]["dblclick"] + "(objInput);");
                            }
                        }
                    }
                });

                $("#" + obj.attr("id")).on("change", "div:eq(1) > table > tbody > tr > td " + typeName, function(ev) {

                    var objInput = $(this);

                    var colIdx = objInput.parent().index() - colNum;

                    if(typeof(objInput[0].tagName) != "undefined"){
                        if(editable && objInput[0].tagName.toLowerCase() == "select"){
                            objInput.parent().parent().find("input[name='" + obj.attr("id") + "__checkbox']").prop("checked", true);
                        }

                        if(editable && objInput[0].tagName.toLowerCase() == "input" && objInput.attr("type") == "radio"){
                            objInput.parent().parent().parent().find("input[name='" + obj.attr("id") + "__checkbox']").prop("checked", true);
                        }
                    }

                    if(colIdx > 0){
                        if(typeof(colGridEvent[colIdx]["change"]) != "undefined" ){
                            if(eval("typeof(" + colGridEvent[colIdx]["change"] + ")") == "function"){
                                eval(colGridEvent[colIdx]["change"] + "(objInput);");
                            }
                        }
                    }
                });
            }

            $("#" + obj.attr("id")).on("click", "div:eq(0) > table > thead > tr > th", function(ev) {

                var objInput = $(this);

                var colIdx = objInput.index() - colNum;

                if(colIdx > -1){
                    if(typeof(colSortableVisible[colIdx]) != "undefined" ){
                        if(colSortableVisible[colIdx] == true){
                            if(eval("typeof(" + callFunc + ")") == "function"){

                                if(typeof(objInput.attr("data-sort")) != "undefined"){

                                    if(objInput.attr("data-sort").indexOf("asc") > -1){
                                        $("#" + obj.attr("id")).addParam("rowOrderChange", objInput.attr("data-col") + " desc");
                                    }
                                    else if(objInput.attr("data-sort").indexOf("desc") > -1){
                                        $("#" + obj.attr("id")).addParam("rowOrderChange", "");
                                    }
                                    else if(objInput.attr("data-sort") == "") {
                                        $("#" + obj.attr("id")).addParam("rowOrderChange", objInput.attr("data-col") + " asc");
                                    }

                                    eval(callFunc+"(1);");
                                }
                            }
                        }
                    }
                }
            });

            obj.addParam("callFunc", callFunc);
            obj.addParam("pageId", pageId);
            obj.addParam("rowOrder[]", rowOrder);
            obj.addParam("rows",rows);
            obj.addParam("maxRows",maxRows);
            obj.addParam("summation[]", summation);
            obj.addParam("editable", editable);
            obj.addParam("paging", paging);
            obj.addParam("excel", excel);
            obj.addParam("isScroll", isScroll);
            obj.addParam("rownNumber", rownNumber);
            obj.addParam("columns_header[]", colNames);
            obj.addParam("filter[]", filter);
            obj.addParam("frozenScroll[]", frozenScroll);
            obj.addParam("columns_name[]", columns_name);
            obj.addParam("columns_width[]", columns_width);
            obj.addParam("columns_edit[]", columns_edit);
            obj.addParam("columns_visible[]", columns_visible);
            obj.addParam("columns_align[]", columns_align);
            obj.addParam("columns_type[]", columns_type);
            obj.addParam("columns_formatter[]", columns_fomatter);
            obj.addParam("columns_formatoptions[]", columns_formatoptions);
            obj.addParam("columns_maxlength[]", columns_maxlength);
            obj.addParam("selectoption[]", colSelectOption);
            obj.addParam("columns_Sortable[]", colSortable);
            obj.addParam("columns_frozen[]", colFrozen);
            obj.addParam("colNum", colNum);

            obj.addParam("hiddenCount", hiddenCount);
            // 스크롤 여부
            obj.addParam("isScroll", isScroll);

            if(editable){
                allCheckEventAdd(obj.attr("id"));
            }

            $("#" + obj.attr("id")).on("dblclick", "div:eq(1) > table > tbody > tr > td", function(ev) {
                rowSelected( obj.attr("id"), $(this).parent());
            });

            if(rowEvent != ""){
                var rowEventItem;
                var clickEvFunc = "";
                var dblclickEvFunc = "";

                for(var item in rowEvent) {
                    rowEventItem = rowEvent[item];

                    if((rowEventItem["callEvent"] || "") == "click"){
                        clickEvFunc = rowEventItem["callEventFunc"] || "";
                    }
                    else if((rowEventItem["callEvent"] || "") == "dblclick"){
                        dblclickEvFunc = rowEventItem["callEventFunc"] || "";
                    }
                }

                if(clickEvFunc != "" && dblclickEvFunc != ""){
                    if(eval("typeof(" + clickEvFunc + ")") == "function"
                        && eval("typeof(" + dblclickEvFunc + ")") == "function"){

                            if(frozenScroll.length <= 0){
                            $("#" + obj.attr("id")).clickDualEventCommon(eval(clickEvFunc),eval(dblclickEvFunc), "div:eq(1) > table > tbody > tr > td");
                        }
                        else{
                            $("#" + obj.attr("id")).clickDualEventCommon(eval(clickEvFunc),eval(dblclickEvFunc), "table:eq(2) > tbody > tr > td");
                            $("#" + obj.attr("id")).clickDualEventCommon(eval(clickEvFunc),eval(dblclickEvFunc), "table:eq(3) > tbody > tr > td");
                        }
                    }
                }
                else if(clickEvFunc != ""){
                    if(frozenScroll.length <= 0){
                        $("#" + obj.attr("id")).on("click", "div:eq(1) > table > tbody > tr > td", function(ev) {
                            if($(this).children("label").children("input[name=\"" + obj.attr("id") + "__checkbox\"]").length <= 0){
                                ev.preventDefault();
                                ev.stopPropagation();

                                if(typeof($(this).parent().attr("data-__empty")) != "undefined") {
                                    return false;
                                }

                                if(eval("typeof(" + clickEvFunc + ")") == "function"){

                                    eval(clickEvFunc + "(ev,$(this).parent());");
                                }
                            }
                        });
                    }
                    else{
                        $("#" + obj.attr("id")).on("click", "table:eq(2) > tbody > tr > td", function(ev) {
                            if($(this).children("label").children("input[name=\"" + obj.attr("id") + "__checkbox\"]").length <= 0){
                                ev.preventDefault();
                                ev.stopPropagation();

                                if(typeof($(this).parent().attr("data-__empty")) != "undefined") {
                                    return false;
                                }

                                if(eval("typeof(" + clickEvFunc + ")") == "function"){

                                    eval(clickEvFunc + "(ev,$(this).parent());");
                                }
                            }
                        });

                        $("#" + obj.attr("id")).on("click", "table:eq(3) > tbody > tr > td", function(ev) {
                            if($(this).children("label").children("input[name=\"" + obj.attr("id") + "__checkbox\"]").length <= 0){
                                ev.preventDefault();
                                ev.stopPropagation();

                                if(typeof($(this).parent().attr("data-__empty")) != "undefined") {
                                    return false;
                                }

                                if(eval("typeof(" + clickEvFunc + ")") == "function"){

                                    eval(clickEvFunc + "(ev,$(this).parent());");
                                }
                            }
                        });
                    }

                }
                else if(dblclickEvFunc != ""){
                    if(frozenScroll.length <= 0){
                        $("#" + obj.attr("id")).on("dblclick", "div:eq(1) > table > tbody > tr > td", function(ev) {
                            if($(this).children("label").children("input[name=\"" + obj.attr("id") + "__checkbox\"]").length <= 0){
                                ev.preventDefault();
                                ev.stopPropagation();

                                // 신창균, 데이터가 없는 경우 더블클릭 이벤트를 실행하지 않도록 함
                                if(typeof($(this).parent().attr("data-__empty")) != "undefined") {
                                    return false;
                                }

                                if(eval("typeof(" + dblclickEvFunc + ")") == "function"){
                                    eval(dblclickEvFunc + "(ev,$(this).parent());");
                                }
                            }
                        });
                    }
                    else{
                        $("#" + obj.attr("id")).on("dblclick", "table:eq(2) > tbody > tr > td", function(ev) {
                            if($(this).children("label").children("input[name=\"" + obj.attr("id") + "__checkbox\"]").length <= 0){
                                ev.preventDefault();
                                ev.stopPropagation();

                                // 신창균, 데이터가 없는 경우 더블클릭 이벤트를 실행하지 않도록 함
                                if(typeof($(this).parent().attr("data-__empty")) != "undefined") {
                                    return false;
                                }

                                if(eval("typeof(" + dblclickEvFunc + ")") == "function"){
                                    eval(dblclickEvFunc + "(ev,$(this).parent());");
                                }
                            }
                        });

                        $("#" + obj.attr("id")).on("dblclick", "table:eq(3) > tbody > tr > td", function(ev) {
                            if($(this).children("label").children("input[name=\"" + obj.attr("id") + "__checkbox\"]").length <= 0){
                                ev.preventDefault();
                                ev.stopPropagation();

                                // 신창균, 데이터가 없는 경우 더블클릭 이벤트를 실행하지 않도록 함
                                if(typeof($(this).parent().attr("data-__empty")) != "undefined") {
                                    return false;
                                }

                                if(eval("typeof(" + dblclickEvFunc + ")") == "function"){
                                    eval(dblclickEvFunc + "(ev,$(this).parent());");
                                }
                            }
                        });
                    }
                }
            }

            // $("#" + obj.attr("id") + " div:eq(1) > table > tbody > tr").each(function(elem, idx){
            //     alert($(this).data("events"));
            // });

            if(callFunc != ""){
                if(pageId != ""){
                    if(paging){
                        paginationLinkEvent("#pagination_" + pageId, callFunc, null, "g_Page_" + pageId, obj.attr("id"));
                    }
                }

                var callGubn = emptyCall[0]["callGubn"];
                var callQueryId = emptyCall[0]["callQueryId"];

                if(callGubn){
                    obj.addParam("query_id", callQueryId);
                    obj.addParam("browser_height", gridContentHeight());

                    $.ajax({
                        method: "post",
                        url: "/sdm/source/CS/empty_table.php",
                        data: jQuery.data(obj[0]),
                        success : function(data, textStatus, jqXHR){
                            $("#" + obj.attr("id")).html(data);
                        },
                        error: function(data, textStatus, jqXHR){
                        },
                        dataType: "html"
                    });
                }else{
                    if(autoSearch){
                        eval(callFunc+"(1);");
                    }
                }

                obj.removeData("callQueryId");
                obj.removeData("browser_height");
            }

            // 그리드 상의 버튼 이벤트
            for(var i = 0; i < columns_type.length; i++) {
                if(columns_type[i].indexOf("button") > -1) {
                    if(columns_formatoptions[i].length > 0) {
                        var btnNames = columns_formatoptions[i].split(",");
                        for(var j = 0; j < btnNames.length; j++) {
                            // 이벤트 달아줌
                            $("#" + obj.attr("id")).on("click", "button[name='" + btnNames[j] + "']", function(ev) {
                                var paramObject = $(this);

                                if(eval("typeof(click_" + paramObject.attr("name") + ")") != "function") {
                                    alert("click_" + paramObject.attr("name") + " 함수가 정의되지 않았습니다.");
                                } else {
                                    eval("click_" + paramObject.attr("name") + "(ev, paramObject);");
                                }
                            });
                        }
                    }
                }
            }

            // 라디오 버튼이 있는 경우, 헤더에 있는 라디오 버튼을 클릭하면 전체선택이 되도록 한다.
            $("#" + obj.attr("id")).on("change", "input[type='radio'][data-common-table-radio-header]", function(ev) {
                var thisObj = $(this);
                $("#" + obj.attr("id") + " input[data-common-table-radio='" + obj.attr("id") + "'][value='" + thisObj.val() + "']").prop("checked", true);
            });
        };

        $.fn.setColumns = function(colDbNames){
            var obj = $(this);

            var colNames = obj.getParam("columns_header[]");

            if(colNames.length != colDbNames.length){
                alert("setColumns 함수 컬럼 개수가 일치하지 않습니다");
                return;
            }

            obj.addParam("colDbNames[]", colDbNames);
        };

        $.fn.emptyRow = function(){
            var obj = $(this);
            var obj_id = $(this).attr("id");
            var editable = obj.getParam("editable");
            var rownNumber = obj.getParam("rownNumber");
            var colDbNames = obj.getParam("colDbNames[]");
            var columns_header = obj.getParam("columns_header[]");
            var filter = obj.getParam("filter[]");
            var frozenScroll = obj.getParam("frozenScroll[]");
            var columns_width = obj.getParam("columns_width[]");
            var columns_edit = obj.getParam("columns_edit[]");
            var columns_visible = obj.getParam("columns_visible[]");
            var columns_align = obj.getParam("columns_align[]");
            var columns_type = obj.getParam("columns_type[]");
            var columns_formatter = obj.getParam("columns_formatter[]");
            var columns_formatoptions = obj.getParam("columns_formatoptions[]");
            var columns_selectoption = obj.getParam("selectoption[]");
            var columns_maxlength = obj.getParam("columns_maxlength[]");
            var columns_frozen = obj.getParam("columns_frozen[]");

            var readonlyStr = "";
            var disabledStr = "";

            if(colDbNames.length <= 0){
                alert("setColumns가 선언되지 않았습니다");
                return;
            }

            var row_html = "";

            row_html = "<tr ";
            for(var i=0; i<colDbNames.length; i++){
                row_html += "data-" + colDbNames[i] + "=\"\" ";
            }

            row_html += ">";

            if(editable){
                row_html += "<td scope=\"row\" class=\"text-center\"><label style=\"margin:0px; width:100%\"><input type=\"checkbox\" name=\"" + obj_id + "__checkbox\" /></label></td>"
            }

            if(rownNumber){
                row_html += "<td class=\"text-center\"></td>"
            }

            for(var i=0; i<colDbNames.length; i++){
                if(!columns_edit[i]){
                    readonlyStr = " readonly = \"readonly\" ";
                    disabledStr = " disabled = \"disabled\" ";
                }
                else{
                    readonlyStr = "";
                    disabledStr = "";
                }

                if(!columns_visible[i]){
                    row_html += "<input type=\"hidden\" name=\"" + colDbNames[i] + "\" value=\"\" />";
                }else if(columns_visible[i]){
                    if(columns_type[i] == "checkbox"){
                        row_html += "<td scope=\"row\" class=\"text-center\"><label style=\"margin:0px; width:100%\"><input type=\"checkbox\" name=\"" + colDbNames[i] + "\" /></label></td>";
                    }
                    else if(columns_type[i] == "input"){
                        row_html += "<td scope=\"row\">";
                        if(columns_formatter[i] == "number"){
                            row_html += "<input type=\"text\" class=\"form-control table-grid-input text-" + columns_align[i] + " jQueryNumericInputCheck\" name=\"" + colDbNames[i] + "\" value=\"\" " + readonlyStr + " maxlength=\"" + columns_maxlength[i] + "\" />";
                        }
                        else if(columns_formatter[i] == "alphanum"){
                            row_html += "<input type=\"text\" class=\"form-control table-grid-input text-" + columns_align[i] + " jQueryAlphaCodeInputCheck\" name=\"" + colDbNames[i] + "\" value=\"\" " + readonlyStr + " maxlength=\"" + columns_maxlength[i] + "\" />";
                        }
                        else if(columns_formatter[i] == "date"){
                            row_html += "<input type=\"text\" class=\"form-control table-grid-input text-" + columns_align[i] + "\" name=\"" + colDbNames[i] + "\" value=\"\" " + readonlyStr + " maxlength=\"" + columns_maxlength[i] + "\" />";
                        }
                        else{
                            row_html += "<input type=\"text\" class=\"form-control table-grid-input text-" + columns_align[i] + "\" name=\"" + colDbNames[i] + "\" value=\"\" " + readonlyStr + " maxlength=\"" + columns_maxlength[i] + "\" />";
                        }
                        row_html += "</td>";
                    }
                    else if(columns_type[i] == "textarea"){
                        row_html += "<td scope=\"row\" class=\"text-center\"><textarea name=\"" + colDbNames[i] + "\" " + readonlyStr + "></textarea></td>";
                    }
                    else if(columns_type[i] == "select"){
                        row_html += "<td scope=\"row\" class=\"text-center\"><select name=\"" + colDbNames[i] + "\" class=\"form-control table-grid-input\" " + disabledStr + ">";

                        if(typeof(columns_selectoption[i]) == "function"){
                            var get_json = columns_selectoption[i].call();
                            var select_html = "";

                            if(get_json["allCheck"]){
                                select_html += "<option value=\"\">" + get_json["allCheckString"] + "</option>";
                            }

                            for(var item in get_json["data"]){
                                select_html += "<option value=\"" + get_json["data"][item]["value"] + "\">" + get_json["data"][item]["title"] + "</option>";
                            }
                        }

                        row_html += select_html;
                        row_html += "</select><input type=\"hidden\" name=\"select_" + colDbNames[i] + "\" value=\"\" /></td>";
                    }
                    else{
                        row_html += "<td class=\"text-" + columns_align[i] + "\"></td>";
                    }
                }
            }

            row_html += "</tr>";

            return row_html;
        };

        $.fn.appendRow = function(){
            var obj = $(this);
            var obj_id = $(this).attr("id");
            var row_html = obj.emptyRow();

            // 신창균, 데이터가 없는 경우에 해당 tr을 삭제 후 처리
            if(typeof($("#" + obj_id + " tbody tr td:eq(0)").attr("colspan")) != "undefined") {
                $("#" + obj_id + " tbody tr").remove();
            }

            $("#" + obj_id + " tbody").append(row_html);

        };

        $.fn.prependRow = function(){
            var obj = $(this);
            var obj_id = $(this).attr("id");
            var row_html = obj.emptyRow();

            // 신창균, 데이터가 없는 경우에 해당 tr을 삭제 후 처리
            if(typeof($("#" + obj_id + " tbody tr td:eq(0)").attr("colspan")) != "undefined") {
                $("#" + obj_id + " tbody tr").remove();
            }

            $("#" + obj_id + " tbody").prepend(row_html);
        };

        // 객체의 action 속성의 값을 변경
        $.fn.setAction = function(p_action){
            var obj = $(this);

            obj.prop("action", p_action);
            obj.addParam("setAction", true);
        };

        $.fn.removeAction = function(){
            var obj = $(this);

            obj.prop("action", "");
            obj.removeData("setAction");
        }

        // 객체의 action 속성의 값을 가져옴
        $.fn.getAction = function(){
            var obj = $(this);

            obj.prop("action");
        };

        // 객체의 method 속성의 값을 변경
        $.fn.setMehtod = function(p_method){
            var obj = $(this);

            obj.prop("method", p_method);
        };

        // 객체의 data에 값을 추가해줌
        $.fn.addParam = function(keyStr,valueStr){
            var obj = $(this)[0];

            jQuery.data(obj, keyStr, valueStr);
        };

        // 객체의 data에 값을 가져옴
        $.fn.getParam = function(keyStr, p_defaultValue){
            var obj = $(this)[0];
            var defaultValue = p_defaultValue || "";

            if(typeof(jQuery.data(obj, keyStr)) == "undefined"){
                return defaultValue;
            }
            else{
                return jQuery.data(obj, keyStr);
            }

        }

        $.fn.request = function(){
            var obj = $(this);
            var obj_id = $(this).attr("id");
            var funcName = obj.getParam("func") || "";
            var result = obj.getParam("result") || "";
            var dataType = obj.getParam("dataType") || "";
            var methodType = obj.prop("method") || "post";
            var afterAction;

            if(typeof(obj.getParam("afterAction")) == "boolean"){
                afterAction = obj.getParam("afterAction");
            }
            else if(typeof(obj.getParam("afterAction")) != "undefined"){
                if(obj.getParam("afterAction") == ""){
                    afterAction = true;
                }
            }
            else{
                afterAction = true;
            }

            var resultid = "";

            obj.addParam("obj_id", obj_id);
            obj.addParam("rowCountCustom", "");

            if(result != ""){

                obj.addParam("rowCountCustom", result.getParam("rows"));
                obj.addParam("maxRows", result.getParam("maxRows"));
                obj.addParam("callFunc", result.getParam("callFunc"));
                obj.addParam("rowOrder[]", result.getParam("rowOrder[]"));
                obj.addParam("summation[]", result.getParam("summation[]"));
                obj.addParam("rowOrderChange", result.getParam("rowOrderChange"));
                obj.addParam("pageId", result.getParam("pageId"));
                obj.addParam("editable", result.getParam("editable"));
                obj.addParam("paging", result.getParam("paging"));
                obj.addParam("excel", result.getParam("excel"));
                obj.addParam("isScroll", result.getParam("isScroll"));
                obj.addParam("rownNumber", result.getParam("rownNumber"));
                obj.addParam("columns_header[]", result.getParam("columns_header[]"));
                obj.addParam("filter[]", result.getParam("filter[]"));
                obj.addParam("frozenScroll[]", result.getParam("frozenScroll[]"));
                obj.addParam("columns_name[]", result.getParam("columns_name[]"));
                obj.addParam("columns_width[]", result.getParam("columns_width[]"));
                obj.addParam("columns_edit[]", result.getParam("columns_edit[]"));
                obj.addParam("columns_visible[]", result.getParam("columns_visible[]"));
                obj.addParam("columns_align[]", result.getParam("columns_align[]"));
                obj.addParam("columns_type[]", result.getParam("columns_type[]"));
                obj.addParam("columns_formatter[]", result.getParam("columns_formatter[]"));
                obj.addParam("columns_formatoptions[]", result.getParam("columns_formatoptions[]"));
                obj.addParam("columns_Sortable[]", result.getParam("columns_Sortable[]"));
                obj.addParam("columns_frozen[]", result.getParam("columns_frozen[]"));

                obj.addParam("columns_maxlength[]", result.getParam("columns_maxlength[]"));
                obj.addParam("browser_height", gridContentHeight());

                resultid = $(result).attr("id") || "";
                obj.addParam("result_width", $("#" + resultid).width());

                obj.removeData("result");
            }

            obj.addParam("result_id", resultid);

            var objAction = obj.getParam("setAction") || false;

            if(funcName.startsWith("IQ")){
                obj.serializeArrayCustom();
                if(!objAction){
                    if(dataType == "json"){
                        obj.setAction("/sdm/source/CS/common_table_json.php");
                    }
                    else{
                        obj.setAction("/common_table");
                    }
                }
                if(dataType == ""){
                    obj.addParam("dataType","html");
                    dataType = "html";
                }
            }
            else if(funcName.startsWith("CK")){
                if(!objAction){
                    obj.setAction("/sdm/source/CS/common_check.php");
                }
                if(dataType == ""){
                    obj.addParam("dataType","json");
                    dataType = "json";
                }
            }
            else if(funcName.startsWith("ID")){
                obj.serializeArrayCustom();
                if(!objAction){
                    obj.setAction("/sdm/source/CS/common_detail.php");
                }
                if(dataType == ""){
                    obj.addParam("dataType","json");
                    dataType = "json";
                }
            }
            else if(funcName.startsWith("IS")){
                if(!objAction){
                    obj.setAction("/sdm/source/CS/common_insert.php");
                }
                if(dataType == ""){
                    obj.addParam("dataType","json");
                    dataType = "json";
                }
            }
            else if(funcName.startsWith("DL")){
                if(!objAction){
                    obj.setAction("/sdm/source/CS/common_delete.php");
                }
                if(dataType == ""){
                    obj.addParam("dataType","json");
                    dataType = "json";
                }
            }
            else if(funcName.startsWith("EX")){
                if(!objAction){
                    obj.setAction("/sdm/source/CS/common_excel.php");
                }

                var ex_columns_header = result.getParam("columns_header[]")
                var ex_columns_visible = result.getParam("columns_visible[]");
                var rowOrderChange = result.getParam("rowOrderChange");
                var rowOrder = result.getParam("rowOrder[]");
                var filter = result.getParam("filter[]");
                var excel_title = obj.getParam("excel_title");
                var filename = obj.getParam("filename");
                var grid_title = "&__EX_GRID_TITLE=";

                var str = obj.serializeArrayCustomEX();
                var str2 = obj.serialize();

                for(var i=0; i<ex_columns_header.length; i++){
                    if(ex_columns_visible[i]){
                        grid_title = grid_title + ex_columns_header[i] + "|";
                    }
                    else{
                        grid_title = grid_title + "__N|";
                    }
                }

                grid_title.substring(0, grid_title.length -1)

                location.href = obj.prop("action") + "?query_id=" + obj.getParam("query_id") + str + grid_title.substring(0, grid_title.length -1) + "&excel_title=" + excel_title + "&filename=" + filename + "&rowOrderChange=" + rowOrderChange + "&rowOrder=" + rowOrder + "&filter=" + filter + "&" + str2;

                obj.removeData();
                obj.removeData("setAction");
                return;
            }
            else if(funcName.startsWith("PT")){
                if(!objAction){
                    obj.setAction("/sdm/source/CS/common_print.php");
                }

                var wSize = obj.getParam("popup_width") == "" ? 100: Number(obj.getParam("popup_width"));
                var hSize = obj.getParam("popup_height") == "" ? 100: Number(obj.getParam("popup_height"));

                var str = obj.serialize();
                OpenPopup(obj.prop("action") + "?query_id=" + obj.getParam("query_id") + "&" + str, obj.getParam("query_id"), hSize, wSize, true, true, false);

                obj.removeData();
                obj.removeData("setAction");
                return;
            }

            obj.removeData("setAction");


            $.ajax({
                method: methodType,
                url: obj.prop("action"),
                data: jQuery.data(obj[0]),
                success : function(data, textStatus, jqXHR){

                    changeLoadingImageStatus(true);
                    //$("#entire_loading_image").css("display", "block");

                    if(resultid != ""){
                        $("#" + resultid).html(data);

                        var result_columns_type = result.getParam("columns_type[]");
                        var result_selectoption = result.getParam("selectoption[]");
                        var result_columns_visible = result.getParam("columns_visible[]");
                        var colNum = result.getParam("colNum");
                        var result_columns_formatter = result.getParam("columns_formatter[]");
                        var result_columns_formatoptions = result.getParam("columns_formatoptions[]");

                        var colIndex = 0;

                        for(var i=0; i<result_columns_type.length; i++){
                            if(result_columns_visible[i]){

                                if(result_columns_type[i] == "select"){
                                    if(typeof(result_selectoption[i]) == "function"){
                                        //$("#" + resultid + " td:eq(" + ( colIndex + colNum ) + ") select").html(result_selectoption[i].call());
                                        var get_json = result_selectoption[i].call();
                                        var set_html = "";
                                        var sel_str = "";
                                        var hiddenValue = "";

                                        $("#" + resultid + " tbody tr").each(function(idx, elem){
                                            set_html = "";
                                            hiddenValue = $(this).children("td:eq(" + (colIndex + colNum) + ")").children("input[type='hidden']").val();

                                            if(get_json["allCheck"]){
                                                set_html = "<option value=\"\">" + get_json["allCheckString"] + "</option>";
                                            }

                                            for(var item in get_json["data"]){
                                                sel_str = "";
                                                if(hiddenValue == get_json["data"][item]["value"]){
                                                    sel_str = " selected=\"selected\"";
                                                }
                                                set_html += "<option value=\"" + get_json["data"][item]["value"] + "\"" + sel_str + ">" + get_json["data"][item]["title"] + "</option>";
                                            }

                                            $(this).children("td:eq(" + (colIndex + colNum) + ")").children("select").html(set_html);
                                        });
                                    }
                                } else if(result_columns_type[i] == "input" && result_columns_formatter[i] == "date") {
                                    $("#" + resultid + " tbody tr").each(function(idx, elem) {
                                        // 일/월/년 모드 (days/months/years)
                                        var datepicker_formatter = "";
                                        if(result_columns_formatoptions[i] == "days" || result_columns_formatoptions[i] == "") {
                                            datepicker_formatter = "yyyy-mm-dd";
                                        } else if(result_columns_formatoptions[i] == "months") {
                                            datepicker_formatter = "yyyy-mm";
                                        } else if(result_columns_formatoptions[i] == "years") {
                                            datepicker_formatter = "yyyy";
                                        } else {
                                            datepicker_formatter = "yyyy-mm-dd";
                                        }
                                        var datepicker_options = {
                                            format: datepicker_formatter,
                                            minViewMode: result_columns_formatoptions[i],
                                            autoclose: true
                                        };
                                        $(this).children("td:eq(" + (colIndex + colNum) + ")").children("[data-colattr='datepicker']").datepicker(datepicker_options);
                                    });
                                }

                                colIndex++;
                            }
                        }
                    }
                    else if(funcName.startsWith("ID")){
                        if(afterAction){
                            // 데이터 개수 판단
                            if(data["count"] > 0) {
                                // 팝업내용 초기화
                                var modal = $("#" + obj_id);

                                modal.modalSet(data);
                                if($("#" + obj_id).parents("div.modal").length > 0){
                                    $("#" + obj_id).parents("div.modal").modal('show');
                                }
                            } else {
                                alert(data["message"]);
                            }
                        }
                    }
                    else if(funcName.startsWith("IS")){
                        if(afterAction){
                            alert(data["message"]);
                            if(data["count"] > 0) {
                                if($("#" + obj_id).parents("div.modal").length > 0){
                                    $("#" + obj_id).parents("div.modal").modal('hide');
                                }
                            }
                        }
                    }
                    else if(funcName.startsWith("DL")){
                        if(afterAction){
                            alert(data["message"]);
                            if(data["count"] > 0) {
                                if($("#" + obj_id).parents("div.modal").length > 0){
                                    $("#" + obj_id).parents("div.modal").modal('hide');
                                }
                            }
                        }
                    }

                    obj.removeData();

                    if(eval("typeof(handle"+funcName+")") == 'function') {
                        eval("handle"+funcName+"(data, textStatus, jqXHR);");
                    }

                    changeLoadingImageStatus(false);
                },
                error: function(data, textStatus, jqXHR){
                    obj.removeData();
                },
                dataType: dataType
            });


        };

        // 객체 안에 있는 모든 태그들의 정보들을 객체의 data 부분에 push
        $.fn.serializeArrayCustom = function(){
            var obj = $(this);
            var elemObj;
            var chkValue = {};

            $("#" + obj.attr("id") + " *").each(function(idx, elem) {
                elemObj = $(elem);

                if(elemObj[0].tagName.toLowerCase() == "input") {
                    if(elemObj.attr("type") == "text" || elemObj.attr("type") == "hidden"){
                        if(typeof(elemObj.attr("name")) == "undefined"){
                            alert("name 속성을 찾을 수 없습니다.");
                            return false;
                        }

                        if(elemObj.hasClass("jQueryNumericInputCheck")){
                            obj.addParam(elemObj.attr("name"), elemObj.val().replace(/,/gi,""));
                        }else{
                            obj.addParam(elemObj.attr("name"), elemObj.val());
                        }
                    }else if(elemObj.attr("type") == "radio"){
                        if(elemObj.is(":checked")){
                            if(typeof(elemObj.attr("name")) == "undefined"){
                                alert("name 속성을 찾을 수 없습니다.");
                                return false;
                            }
                            obj.addParam(elemObj.attr("name"), elemObj.val());
                        }
                    }else if(elemObj.attr("type") == "checkbox"){
                        if(elemObj.is(":checked")){
                            if(typeof(elemObj.attr("name")) == "undefined"){
                                alert("name 속성을 찾을 수 없습니다.");
                                return false;
                            }
                            //obj.addParam(elemObj.attr("name")+"[]", elemObj.val());
                            if(typeof(chkValue[elemObj.attr("name")+"[]"]) == "undefined"){
                                chkValue[elemObj.attr("name")+"[]"] = [];
                            }
                            chkValue[elemObj.attr("name")+"[]"].push(elemObj.val());
                        }
                    }
                }else if(elemObj[0].tagName.toLowerCase() == "textarea") {
                    if(typeof(elemObj.attr("name")) == "undefined"){
                        alert("name 속성을 찾을 수 없습니다.");
                        return false;
                    }
                    obj.addParam(elemObj.attr("name"), elemObj.val());
                }else if(elemObj[0].tagName.toLowerCase() == "select") {
                    if(typeof(elemObj.attr("name")) == "undefined"){
                        alert("name 속성을 찾을 수 없습니다.");
                        return false;
                    }
                    obj.addParam(elemObj.attr("name"), elemObj.val());
                }
            });

            for(var item in chkValue){
                obj.addParam(item, chkValue[item]);
            }
        };

        // 객체 안에 있는 모든 태그들의 정보들을 객체의 data 부분에 push (엑셀전용)
        $.fn.serializeArrayCustomEX = function(){
            var obj = $(this);
            var elemObj;
            var chkValue = {};
            var returnStr = "";
            var titleName = "";
            var checkboxIdx = 1;

            $("#" + obj.attr("id") + " *").each(function(idx, elem) {
                elemObj = $(elem);

                if(elemObj[0].tagName.toLowerCase() == "input") {
                    if(elemObj.attr("type") == "text"){
                        if(elemObj.hasClass("jQueryNumericInputCheck")){
                            returnStr = returnStr + "&__EX" + elemObj.attr("name") + "=" + elemObj.val().replace(/,/gi,"");
                        }else{
                            if(elemObj.parent().children("div").children("span.input-group-text").length > 1){
                                if(elemObj.index() <= 2){
                                    returnStr = returnStr + "&__EX" + elemObj.attr("name") + "=" + encodeURIComponent(elemObj.val());
                                }
                                else{
                                    returnStr = returnStr + " " + elemObj.parent().children("div").children("span.input-group-text:eq(1)").text() + " " +  encodeURIComponent(elemObj.val());
                                }
                            }
                            else{
                                returnStr = returnStr + "&__EX" + elemObj.attr("name") + "=" + encodeURIComponent(elemObj.val());
                            }
                        }
                    }else if(elemObj.attr("type") == "radio"){
                        if(elemObj.is(":checked")){
                            returnStr = returnStr + "&__EX" + elemObj.attr("name") + "=" + elemObj.val();
                        }
                    }else if(elemObj.attr("type") == "checkbox"){
                        if(elemObj.is(":checked")){
                            // if(typeof(chkValue[elemObj.attr("name")+"[]"]) == "undefined"){
                            //     chkValue[elemObj.attr("name")+"[]"] = [];
                            // }
                            // chkValue[elemObj.attr("name")+"[]"].push(elemObj.val());
                            // returnStr = returnStr + "&__EX" + elemObj.attr("name") + checkboxIdx + "=" + elemObj.val();
                            // checkboxIdx++;
                        }
                    }
                    if(elemObj.attr("type") == "checkbox"){
                        // titleName = elemObj.parent().text() + "|";
                    }
                    else{
                        if(elemObj.index() <= 2){
                            titleName = titleName + elemObj.parent().children("div").children("span.input-group-text:eq(0)").text() + "|";
                        }
                    }
                }else if(elemObj[0].tagName.toLowerCase() == "textarea") {
                    returnStr = returnStr + "&__EX" + elemObj.attr("name") + "=" + encodeURIComponent(elemObj.val());

                    if(elemObj.index() <= 2){
                        titleName = titleName + elemObj.parent().children("div").children("span.input-group-text:eq(0)").text() + "|";
                    }
                }else if(elemObj[0].tagName.toLowerCase() == "select") {
                    if(elemObj.parent().children("div").children("span.input-group-text").length > 1){
                        if(elemObj.index() <= 2){
                            returnStr = returnStr + "&__EX" + elemObj.attr("name") + "=" + encodeURIComponent(elemObj.children("option:selected").text());
                        }
                        else{
                            returnStr = returnStr + " " + elemObj.parent().children("div").children("span.input-group-text:eq(1)").text() + " " +  encodeURIComponent(elemObj.children("option:selected").text());
                        }
                    }
                    else{
                        returnStr = returnStr + "&__EX" + elemObj.attr("name") + "=" + encodeURIComponent(elemObj.children("option:selected").text());
                    }

                    if(elemObj.index() <= 2){
                        titleName = titleName + elemObj.parent().children("div").children("span.input-group-text:eq(0)").text() + "|";
                    }
                }
            });

            // for(var item in chkValue){
            //     //obj.addParam("__EX" + item, chkValue[item]);
            //     returnStr = returnStr + "&__EX" + item + "=" + chkValue[item];
            // }

            return returnStr + "&__EX_TITLE=" + encodeURIComponent(titleName.substring(0, titleName.length -1));
        };

        // 그리드의 기본 체크박스 활성화시(editable:true)
        // 그리드의 체크된 행이 있는지 확인
        // 0 : 체크된 부분 없음
        // 1 : 체크된 부분 있음
        $.fn.nonCheck = function(){
            var obj_id = $(this).attr("id");

            if($("#" + obj_id + " input[name='" + obj_id + "__checkbox']:checked").length < 1) {
				return 0;
			}

            return 1;
        }

        // 그리드의 행의 존재 유무 확인
        // 0 : 데이터 없음
        // 1 : 데이터 있음
        $.fn.nonData = function(){
            var obj_id = $(this).attr("id");

            if($("#" + obj_id + " tbody tr").length < 1) {
				return 0;
			}

            return 1;
        }

        $.fn.getCheckGridDataArray = function(_grdObj){
            var obj = $(this);
            var obj_id = _grdObj;
            var params = {};
            var attrObj;
            var eleObj;
            var rownumber = (obj.getParam("rownNumber") ? 1 : 0);
            var editable = (obj.getParam("editable") ? 1 : 0);
            var colIndex = 0;

            $("#" + obj_id + " input[name='" + obj_id + "__checkbox']:checked").each(function(idx, elem) {
				var objTr = $(elem).parent().parent().parent();

                for(var i=0; i < objTr[0].attributes.length; i++){
                    attrObj = objTr[0].attributes[i];
                    eleObj = objTr.find("[name='" + attrObj.name.replace("data-","") + "']");

                    if(attrObj.name.indexOf("data-") > -1){
                        if(typeof(params["grd_" + attrObj.name.replace("data-","") + "[]"]) == 'undefined') {
                            params["grd_" + attrObj.name.replace("data-","") + "[]"] = [];
                        }

                        if(eleObj.length > 0){
                            // 포함된 element 가 있음 (input, select, textarea)
                            if(eleObj.attr("type") == "checkbox"){
                                params["grd_" + attrObj.name.replace("data-","") + "[]"].push(eleObj.is(":checked"));
                            }
                            else{
                                params["grd_" + attrObj.name.replace("data-","") + "[]"].push(eleObj.val());
                            }
                        }
                        else{
                            params["grd_" + attrObj.name.replace("data-","") + "[]"].push(attrObj.value);
                        }

                        colIndex++;
                    }
                }
			});

            for(var s in params) {
                obj.addParam(s, params[s]);
            }
        }

        $.fn.getGridDataArray = function(_grdObj){
            var obj = $(this);
            var obj_id = _grdObj;
            var params = {};
            var attrObj;
            var eleObj;
            var rownumber = (obj.getParam("rownNumber") ? 1 : 0);
            var editable = (obj.getParam("editable") ? 1 : 0);
            var colIndex = 0;

            $("#" + obj_id + " tbody tr").each(function(idx, elem) {
				var objTr = $(elem);

                for(var i=0; i < objTr[0].attributes.length; i++){
                    attrObj = objTr[0].attributes[i];
                    eleObj = objTr.find("[name='" + attrObj.name.replace("data-","") + "']");

                    if(attrObj.name.indexOf("data-") > -1){
                        if(typeof(params["grd_" + attrObj.name.replace("data-","") + "[]"]) == 'undefined') {
                            params["grd_" + attrObj.name.replace("data-","") + "[]"] = [];
                        }

                        if(eleObj.length > 0){
                            // 포함된 element 가 있음 (input, select, textarea)
                            if(eleObj.attr("type") == "checkbox"){
                                params["grd_" + attrObj.name.replace("data-","") + "[]"].push(eleObj.is(":checked"));
                            }
                            else{
                                params["grd_" + attrObj.name.replace("data-","") + "[]"].push(eleObj.val());
                            }
                        }
                        else{
                            params["grd_" + attrObj.name.replace("data-","") + "[]"].push(attrObj.value);
                        }

                        colIndex++;
                    }
                }
			});

            for(var s in params) {
                obj.addParam(s, params[s]);
            }
        }

        // 그리드의 체크된 행의 attr 속성의 값을 가져옴
        // dataKey : 조회 쿼리의 컬럼 이름
        $.fn.getGridData = function(dataKey){
            var obj_id = $(this).attr("id");
            var params = [];

			$("#" + obj_id + " input[name='" + obj_id + "__checkbox']:checked").each(function(idx, elem) {
				var obj = $(elem);
				params.push(obj.parent().parent().parent().attr("data-" + dataKey));
			});

            return params;
        };

        // 그리드의 체크된 행의 element 안의 값을 가져옴
        // datatype : element 종류 (input,select,checkbox,textarea)
        // dataKey : element 의 name 속성의 값
        $.fn.getGridElementData = function(datatype, dataKey){
            var obj_id = $(this).attr("id");
            var params = [];

			$("#" + obj_id + " input[name='" + obj_id + "__checkbox']:checked").each(function(idx, elem) {
				var obj = $(elem);
                var objTag = obj.parent().parent().parent().find(datatype + "[name='" + dataKey + "']");

                if(objTag.attr("type") == "checkbox"){
                    params.push(objTag.is(":checked"));
                }
                else{
                    params.push(objTag.val());
                }
			});

            return params;
        };

        // 그리드의 체크된 행의 td의 값 을 가져옴
        // dataCol : td 의 index 값
        // p_formatter : 포맷타입 종류 ( number ) [옵션 값이라서 넣지 않아도 무관]
        $.fn.getGridTdData = function(dataCol, p_formatter){
            var obj_id = $(this).attr("id");
            var formatter = p_formatter || "";
            var params = [];

            $("#" + obj_id + " input[name='" + obj_id + "__checkbox']:checked").each(function(idx, elem) {
                var obj = $(elem);
                if(formatter == "number"){
                    params.push(obj.parent().parent().parent().children("td:eq(" + dataCol + ")").text().replace(/,/gi,""));
                }else{
                    params.push(obj.parent().parent().parent().children("td:eq(" + dataCol + ")").text());
                }
            });

            return params;
        };

        // 그리드의 체크된 행 개수 만큼으로 배열을 생성해줌
        // dataValue : 배열로 만드려고 하는 값
        $.fn.createArrayData = function(dataValue){
            var obj_id = $(this).attr("id");
            var params = [];

			$("#" + obj_id + " input[name='" + obj_id + "__checkbox']:checked").each(function(idx, elem) {
				params.push(dataValue);
			});

            return params;
        };

        // 그리드의 모든 행의 attr 속성의 값을 가져옴
        // dataKey : 조회 쿼리의 컬럼 이름
        $.fn.getGridAllData = function(dataKey){
            var obj_id = $(this).attr("id");
            var params = [];

			$("#" + obj_id + " tbody tr").each(function(idx, elem) {
				var obj = $(elem);
				params.push(obj.attr("data-" + dataKey));
			});

            return params;
        };

        // 그리드의 모든 행의 값을 가져옴
        // datatype : element 종류 (input,select,checkbox,textarea)
        // dataKey : element 의 name 속성의 값
        $.fn.getGridElementAllData = function(datatype, dataKey){
            var obj_id = $(this).attr("id");
            var params = [];

			$("#" + obj_id + " tbody tr").each(function(idx, elem) {
				var obj = $(elem);
                var objTag = obj.find(datatype + "[name='" + dataKey + "']");

                if(objTag.attr("type") == "checkbox"){
                    params.push(objTag.is(":checked"));
                }
                else{
                    params.push(objTag.val());
                }
			});

            return params;
        };

        // 그리드의 모든 행의 td의 값 을 가져옴
        // dataCol : td 의 index 값
        // p_formatter : 포맷타입 종류 ( number ) [옵션 값이라서 넣지 않아도 무관]
        $.fn.getGridTdAllData = function(dataCol, p_formatter){
            var obj_id = $(this).attr("id");
            var formatter = p_formatter || "";
            var params = [];

            $("#" + obj_id + " tbody tr").each(function(idx, elem) {
                var obj = $(elem);
                if(formatter == "number"){
                    params.push(obj.children("td:eq(" + dataCol + ")").text().replace(/,/gi,""));
                }else{
                    params.push(obj.children("td:eq(" + dataCol + ")").text());
                }
            });

            return params;
        };

        // 모달 창 초기화
        // 모든 element 들을 초기화 시켜줌
        $.fn.modalClear = function(){
            var obj = $(this);

            // 팝업 내용 전부 초기화
            $("#" + obj.attr("id") + " *").each(function(idx, elem) {
                if($(elem)[0].tagName.toLowerCase() == "input") {
                    if($(elem).attr("type") == "text"){
                        if(typeof($(elem).data("datepicker")) != "undefined"){
                            $(elem).attr("data-frameworkDate", "Y");
                            $(elem).datepicker("setDate", DateToStr(new Date(),"-"));
                            $(elem).attr("readonly",false);
                        }else if($(elem).hasClass("jQueryNumericInputCheck")) {
                            $(elem).attr("readonly",false).val("0");
                        }else{
                            if($(elem).attr("data-frameworkDate") == "Y"){
                                initDateOne($(elem).attr("id"));
                                $(elem).attr("readonly",false);
                            }
                            else{
                                $(elem).attr("readonly",false).val("");
                            }
                        }
                    }
                    else if($(elem).attr("type") == "radio"){
                        $(elem).attr("disabled",false).prop("checked", false);
                    }
                    else if($(elem).attr("type") == "checkbox"){
                        $(elem).attr("disabled",false).prop("checked", false);
                    }
                    else if($(elem).attr("type") == "hidden"){
                        $(elem).val("");
                    }
                }else if($(elem)[0].tagName.toLowerCase() == "select") {
                    // 셀렉트박스의 경우 첫번째것 선택
                    $(elem).attr("disabled",false).children("option").eq(0).prop("selected", true).trigger("change");
                }else if($(elem)[0].tagName.toLowerCase() == "option") {
                    // 아무것도 안함..
                }else if($(elem)[0].tagName.toLowerCase() == "textarea") {
                    $(elem).attr("readonly",false).val("");
                }else if($(elem)[0].tagName.toLowerCase() == "span") {
                    if(typeof($(elem).attr("name")) != "undefined" && $(elem).attr("name") != ""){
                        $(elem).text("");
                    }
                }
            });
        };

        // 모달 창의 element들의 readonly, disable 속성 적용
        $.fn.modalSet = function(p_data){
            var obj = $(this);
            var readonlyData = obj.getParam("rdControl[]") || [];
            var disableData = obj.getParam("dsControl[]") || [];
            var itemObj;

            obj.modalClear();

            for(var item in p_data) {
                // count, message 항목은 뿌릴 필요가 없으므로 넘어간다.
                if(item == "count" || item == "message") {
                    continue;
                }

                itemObj = $("#"+item);

                if(itemObj.length > 0){
                    if(itemObj[0].tagName.toLowerCase() == "input"){
                        if(itemObj.attr("type") == "text"){
                            if(typeof(itemObj.data("datepicker")) != "undefined"){
                                itemObj.datepicker("setDate", p_data[item]);
                            }
                            else{
                                itemObj.val(p_data[item]);
                            }
                        } else if(itemObj.attr("type") == "checkbox"){
                            if(p_data[item] == "Y"){
                                itemObj.prop("checked", true);
                            }
                        } else if(itemObj.attr("type") == "hidden"){
                            itemObj.val(p_data[item]);
                        }
                    }
                    else if(itemObj[0].tagName.toLowerCase() == "select"){
                        itemObj.val(p_data[item]);
                    }
                    else if(itemObj[0].tagName.toLowerCase() == "textarea"){
                        itemObj.val(p_data[item]);
                    }
                    else if(itemObj[0].tagName.toLowerCase() == "span"){
                        itemObj.text(p_data[item]);
                    }
                    else{
                        itemObj.val(p_data[item]);
                    }
                }

                $("#" + obj.attr("id") + " *").each(function(idx, elem) {
                    if($(elem)[0].tagName.toLowerCase() == "input") {
                        if($(elem).attr("type") == "radio"){
                            if($(elem).attr("name") == item){
                                if(p_data[item] == $(elem).val()){
                                    $(elem).prop("checked", true);
                                }
                            }
                        }
                    }
                });

                if($("#" + item).hasClass("jQueryNumericInputCheck")){
                    $("#" + item).trigger("focusout");
                }
            }

            for(var i = 0; i < readonlyData.length; i++){
                $("#"+readonlyData[i]).attr("readonly", true);

                if(typeof($("#"+readonlyData[i]).data("datepicker")) != "undefined"){
                    $("#"+readonlyData[i]).datepicker('remove');
                }
            }

            for(var i = 0; i < disableData.length; i++){
                $("#"+disableData[i]).prop("disabled", true);
            }

            obj.removeData();
        };

        // select 변경시 자동 검색
        // funcSearch : 변경 후 호출 하려는 함수 객체
        $.fn.selectAutoSearch = function(funcSearch, exSelect = []){
            var obj = $(this);
            var firstSearch = true;

            $("#" + obj.attr("id") + " select").each(function(idx, elem) {
                firstSearch = true;

                for(var item in exSelect){
                    var SelectId = exSelect[item];

                    if(SelectId == $(elem).attr("id")){
                        firstSearch = false;
                    }
                }

                $(elem).addParam("FirstSearch", firstSearch);
                $(elem).change(function(ev){
                    if(!$(this).getParam("FirstSearch")){
                        $(this).addParam("FirstSearch", true);
                        // console.log("false " + $(this).attr("id"));
                    }
                    else{
                        funcSearch.call(1);
                        // console.log("call " + $(this).attr("id"));
                    }
                });
            });
        };

        // input 변경시 자동 검색
        // funcSearch : 변경 후 호출 하려는 함수 객체
        $.fn.inputAutoSearch = function(funcSearch){
            var obj = $(this);

            $("#" + obj.attr("id") + " input:text").each(function(idx, elem) {
                $(elem).keyup(function(ev){
                    if(ev.keyCode==13 && $(this).attr("type") != 'textarea'){
                        funcSearch.call(1);
                    }
                });
            });
        };

        // 컬럼 순서를 주고, 해당 컬럼의 데이터가 비었는지를 체크
        // 그리드가 그려지는 객체에 사용 가능
        // 빈 값이 있는 경우 false를, 그렇지 않으면 true 를 반환
        // colArray = ["colname1", "colname2", "colname3"]
        // 한 개의 경우 colArray = ["colname"] 과 같이 배열로 선언해야 함
        $.fn.checkGridDataIsEmpty = function(colArray) {

            var obj = $(this);

            var is_error = false;
            var error_msg = "";
            var error_col_idx = 0;

            var col_header = obj.getParam("columns_header[]");
            var rowNumber = obj.getParam("rownNumber")? 1 : 0;
            var is_checkbox = $("#" + obj.attr("id") + "__allCheck").length > 0 ? true : false;

            for(var i = 0; i < colArray.length; i++) {
                obj.find("[name='" + colArray[i] + "']").each(function(idx, elem) {

                    if($(elem).parent().parent().find("[name='" + obj.selector.replace(/#/gi, "") + "__checkbox']:checked").length > 0) {
                        if($.trim($(elem).val()) == "") {
                            is_error = true;
                            error_col_idx = $(elem).parent().index();
                            error_col_idx += ($("input[name='" + obj.selector.replace(/#/gi, "") + "__checkbox']").length > 0 ? -1 : 0);
                            error_msg = col_header[error_col_idx - rowNumber] + " 값은 비어 있으면 안됩니다.";
                            return true;
                        }
                    }
                });

                if(is_error) {
                    break;
                }
            }

            if(is_error) {
                alert(error_msg);
            }

            return !is_error;
        };

        // 2019-01-02 신창균 추가
        // $.fn.loadpage(p_Url);
        // 해당 URL 을 불러오는데, 조회조건을 서버로 넘김 (GET 방식으로 받아옴)
        // ex) $("#frmMain").loadpage("/source/TEST/test.php", ["srch1_name", "srch2_name", ...])
        $.fn.loadpage = function(p_Url, p_ParamArray) {
            //location.pathname
            var obj = $(this);
            var srch_area = $(obj.selector + " *").not("table *").find("select,input,textarea");
            var param_str = "";

            for(var i = 0; i < p_ParamArray.length; i++) {
                param_str += (i == 0 ? "?" : "&");
                param_str += $("[name='" + p_ParamArray[i] + "']").attr("name") + "=" + $("[name='" + p_ParamArray[i] + "']").val();
            }

            location.href = p_Url + param_str;
        };

	}(jQuery));

});
