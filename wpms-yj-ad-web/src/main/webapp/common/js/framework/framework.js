// undefined 상태를 정의함. typeof(undefined) 의 결과는 "undefined" 가 된다.
var undefined = undefined;
var __g_EachRepeatCount = 30; // 기본 값

// startsWith 함수가 없는 경우 prototype 에 추가
String.prototype.startsWith || (String.prototype.startsWith = function(word) {
    return this.lastIndexOf(word, 0) === 0;
});

// 현재 (framework.js) 스크립트의 src 속성 리턴
function getScriptSrc() {
    var script =  document.currentScript || document.querySelector("script[src*='framework.js']");
    return script.src;
}

// src 속성에 있는 특정 파라미터명의 값을 리턴. 없으면 null 리턴
function getScriptParam(key) {
    let src = getScriptSrc();
    let paramStr = src.substring(src.indexOf("?") + 1);
    let params = paramStr.split("&");
    
    for(let i = 0; i < params.length; i++) {
        let kvSplit = params[i].split("=");
        if(kvSplit[0] == key) {
            return kvSplit[1];
        }
    }
    
    return null;
}

// src 속성에 세팅된 모든 키/값을 json 배열 형태로 리턴
function getScriptParams() {
    let src = getScriptSrc();
    let paramStr = src.substring(src.indexOf("?") + 1);
    let params = paramStr.split("&");
    let result = {};
    
    for(let i = 0; i < params.length; i++) {
        let kvSplit = params[i].split("=");
        result[kvSplit[0]] = kvSplit[1];
    }
    
    return result;
}

// 파라미터값 획득
__g_EachRepeatCount = getScriptParam("eachCountNum");
// 파라미터값이 없으면 기본값 할당
__g_EachRepeatCount = __g_EachRepeatCount == undefined || __g_EachRepeatCount == null ? 30 : __g_EachRepeatCount; 

// 모든 그리드 데이터에서 일부 인덱스의 데이터를 폼에 추가하고 그 개수를 리턴하는 함수
function setChunkedGridData(form, allData, stIdx, fnIdx) {

    let params_push = {};
    let dataCount = 0;

    for(let k in allData) {
        // 키 별로 먼저 돌기 때문에 데이터 개수를 중복으로 계산함
        // 마지막으로 추가한 키의 데이터 개수를 리턴하도록 처리
        dataCount = 0;
        for(let i = stIdx; i <= fnIdx; i++) {
            if(i == stIdx) {
                params_push["grd_" + k + "[]"] = [];
            }
            params_push["grd_" + k + "[]"].push(allData[k][i]);
            dataCount++;
        }

        form.addParam("grd_" + k + "[]", params_push);
        params_push = {};
    }

    return dataCount;
}

//모든 그리드 데이터에서 일부 인덱스의 데이터 리턴하는 함수
function getChunkedGridData(allData, stIdx, fnIdx, useOriginKey) {

    let params_push = {};
    useOriginKey = useOriginKey !== true ? false : useOriginKey;

    for(let k in allData) {
        // 키 별로 먼저 돌기 때문에 데이터 개수를 중복으로 계산함
        // 마지막으로 추가한 키의 데이터 개수를 리턴하도록 처리
        dataCount = 0;
        for(let i = stIdx; i <= fnIdx; i++) {
            if(i == stIdx) {
                if(useOriginKey) {
                    params_push[k] = [];
                } else {
                    params_push["grd_" + k + "[]"] = [];
                }
            }
            if(useOriginKey) {
                params_push[k].push(allData[k][i]);
            } else {
                params_push["grd_" + k + "[]"].push(allData[k][i]);
            }
        }
    }

    return params_push;
}

function requestNextData(form, chunkUuid, allGridData, originUrl, actualUrl, send_data, eachCount, totalCount, stIdx, fnIdx, methodType, ajaxType, grid, funcName, baseData, resultid, afterAction, dataType, requestCount) {

    // form             : $("#frmMain") 과 같은 jQuery Form 객체, request 함수에서 설정된 데이터를 사용함
    // chunkUuid        : chunk 하여 업로드 하기 때문에 필요한 UUID (DB의 키값)
    // allGridData      : 전송해야 하는 모든 그리드 데이터 (여기서 일부만 업로드 처리)
    // originUrl        : 원래 요청해야 할 URL, request 함수에서 설정된 데이터를 사용함
    // actualUrl        : 실제 요청하는 URL
    // send_data        : 실제 전송할 데이터
    // eachCount        : 1회 전송시 전송하는 최대 데이터 개수
    // totalCount       : 전송해야 할 전체 그리드 데이터 개수
    // stIdx            : 전송하는 데이터의 시작 index
    // fnIdx            : 전송하는 데이터의 종료 index
    // methodType       : POST / GET 방식, request 함수에서 설정된 데이터를 사용함
    // ajaxType         : 파일 업로드인 경우 "file" / 나머지 값은 기본 데이터 전송, request 함수에서 설정된 데이터를 사용함
    // grid             : 그리드 객체 변수명(ex: _gridHelper), request 함수에서 설정된 데이터를 사용함
    // funcName         : 요청이 어떤 요청인지를 구분하고 handle 함수를 호출하기 위한 데이터, request 함수에서 설정된 데이터를 사용함
    // baseData         : 기본 데이터, request 함수에서 설정된 데이터를 사용함
    // resultid         : 그리드가 표시되는 jQuery 객체, request 함수에서 설정된 데이터를 사용함
    // afterAction      : 완료 후 기본적으로 진행되는 화면 처리를 진행할 것인지의 여부, request 함수에서 설정된 데이터를 사용함
    // dataType         : 데이터의 형식 (기본 json), request 함수에서 설정된 데이터를 사용함
    // requestCount     : 요청 횟수
    
    // 폼에 있는 모든 데이터 remove 처리
    form.removeData();
    
    let curr_pcnt = totalCount - 1 != 0 ? Math.round((fnIdx + 1) / totalCount * 100) : 0;
    // 시작 인덱스는 이전 종료 인덱스에 1을 더할 것
    stIdx = fnIdx + 1;
    // 종료 인덱스는 변경된 시작 인덱스에 1회당 전송 개수 - 1 만큼을 더함
    // 1회당 전송 개수가 1개이면 stIdx == fnIdx
    fnIdx = eachCount > 1 ? stIdx + eachCount - 1 : stIdx;
    // 종료 인덱스가 총 개수 - 1 보다 크면 총 개수 - 1 로 지정
    fnIdx = fnIdx > totalCount - 1 ? totalCount - 1 : fnIdx;
    
    send_data = getChunkedGridData(allGridData, stIdx, fnIdx, true);
    let currDataCount = 0;
    
    // 데이터 개수 알아오기
    if(Object.keys(send_data).length > 0) {
        currDataCount = send_data[Object.keys(send_data)[0]].length;
    }
    
    // 변경된 데이터를 요청에 반영하기 위해 세팅 처리
    form.addParam("originUrl", originUrl);                  // 로직이 처리되는 URL
    form.addParam("requestDataCount", currDataCount);       // 실제 추가된 데이터 개수
    form.addParam("eachDataCount", eachCount);              // 1회 전송시 보내는 최대 개수
    form.addParam("requestTotalCount", totalCount);         // 전체 데이터 개수
    form.addParam("requestStIdx", stIdx);                   // 전송 중인 데이터의 시작 인덱스
    form.addParam("requestFnIdx", fnIdx);                   // 전송 중인 데이터의 종료 인덱스
    form.addParam("chunkUuid", chunkUuid);                  // 키값 전송
    form.addParam("requestCount", requestCount);      // 요청 횟수 추가 후 전송(1이 최초 전송)
    form.addParam("requestDataType", "RDT002");             // RDT001: 단일 데이터(첫 전송만 사용), RDT002: 그리드 데이터(2회차부터 그리드 데이터 전송)
    
    for(let k in form.data()) {
        if(k != "requestContents") {
            send_data[k] = form.data()[k];
        }
    }
    
    form.addParam("requestContents", JSON.stringify(send_data));  // 요청하는 모든 데이터를 JSON 으로 변환하여 전송
    
    // 전송할 그리드 데이터를 다시 설정 (같은 이름으로 addParam 하는 경우 기존 값에 덮어 씌우게 됨)
    send_data = jQuery.data(form[0]);

    $.ajax({
        method: methodType,
        url: actualUrl,
        data: send_data,
        contentType : ajaxType == "file" ? false : "application/x-www-form-urlencoded; charset=UTF-8",
        processData : ajaxType == "file" ? false : true,
        success : function(data, textStatus, jqXHR) {

            let isFinish = false; // 마지막 요청인지 개수로 확인
            // 마지막 요청인지의 여부는 현재 저장중인 마지막 인덱스와 데이터 개수 - 1 을 가지고 비교한다.
            // 추가로 전체 데이터 개수를 1회 요청 개수로 나눈 몫과 나머지가 있으면 1을 더하는 방식으로 요청 횟수를 계산하여 비교한다.
            // 최초에 그리드 데이터가 아닌 일반 데이터를 요청하므로 요청 횟수에서 1을 뺀 다음 비교를 해야 한다.
            // Chunk 를 사용하지 않으면 무조건 마지막 요청으로 간주하고 처리한다.
            // case 1: Chunk 사용시 모두 완료된 경우 또는 Chunk 를 사용하지 않는 경우
            // case 2: Chunk 사용은 하지만 개수로 따졌을 때 완료되지 않은 경우 (중간완료)
            isFinish = (fnIdx >= totalCount - 1) && (requestCount - 1) >= (Math.floor(totalCount / eachCount) + (totalCount % eachCount > 0 ? 1 : 0));

            if(!isFinish) {
                // 아직 완료되지 않은 경우...
                
                // 그리드에서 데이터를 선별하여 변수로 저장
                let chunkedData = getChunkedGridData(allGridData, stIdx, fnIdx, true);
                let currDataCount = 0;
                
                // 데이터 개수 알아오기
                if(Object.keys(chunkedData).length > 0) {
                    currDataCount = chunkedData[Object.keys(chunkedData)[0]].length;
                }
                let curr_pcnt = Math.round((fnIdx + 1) / (totalCount == 0 ? 1 : totalCount) * 100);
                
                // 로딩 화면의 퍼센테이지를 변경
                changeLoadingMessage(curr_pcnt + "% / 100%");

                requestNextData(form, chunkUuid, allGridData, originUrl, actualUrl, send_data, eachCount, totalCount, stIdx, fnIdx, methodType, ajaxType, grid, funcName, baseData, resultid, afterAction, dataType, requestCount + 1);
            } else {
                // 완료된 경우 일반적인 처리
                changeLoadingMessage("처리중입니다..");
                changeLoadingImageStatus(false);

                if(grid != "" && funcName.startsWith("IQ")){
                    eval(grid + ".api.setRowData(JSON.parse(JSON.stringify(data)));");
                    eval(grid + ".setOriginalData(JSON.parse(JSON.stringify(data)));");

                    if(baseData != ""){
                        eval(baseData +"= JSON.parse(JSON.stringify(data));");
                    }

                    setGridHeight(resultid);

                    // g_StackLoadingImageStatus : in common.js
                    if(afterAction && g_ShowResultMessageFlag) {
                        notifyInfo("조회가 완료되었습니다.");
                        g_ShowResultMessageFlag = false;
                    }

                } else if(funcName.startsWith("ID")) {
                    if(afterAction && g_ShowResultMessageFlag) {
                        if(data["count"] > 0) {
                            notifyInfo(data["message"]);
                        } else {
                            notifyDanger(data["message"]);
                        }
                        g_ShowResultMessageFlag = false;
                    }
                } else if(funcName.startsWith("IS")) {
                    if(afterAction && g_ShowResultMessageFlag) {
                        if(data["count"] > 0) {
                            notifyInfo(data["message"]);
                        } else {
                            notifyDanger(data["message"]);
                        }
                        g_ShowResultMessageFlag = false;
                    }
                } else if(funcName.startsWith("DL")) {
                    if(afterAction && g_ShowResultMessageFlag) {
                        if(data["count"] > 0) {
                            notifyInfo(data["message"]);
                        } else {
                            notifyDanger(data["message"]);
                        }
                        g_ShowResultMessageFlag = false;
                    }
                } else if(funcName.startsWith("MD")) {
                    if(afterAction && g_ShowResultMessageFlag) {
                        if(data["count"] > 0) {
                            notifyInfo(data["message"]);
                        } else {
                            notifyDanger(data["message"]);
                        }
                        g_ShowResultMessageFlag = false;
                    }
                }

                form.removeData();

                // 정상 종료인 경우
                if(eval("typeof(handleOK"+funcName+")") == 'function' && data["count"] > 0) {
                    eval("handleOK"+funcName+"(data, textStatus, jqXHR);");
                }

                // http 응답 코드가 200이지만, 내부적으로 오류로 판단한 경우
                if(eval("typeof(handleNO"+funcName+")") == 'function' && data["count"] <= 0) {
                    eval("handleNO"+funcName+"(data, textStatus, jqXHR);");
                }

                // 앞의 두 가지 처리 후 마지막으로 공통 처리
                if(eval("typeof(handle"+funcName+")") == 'function') {
                    eval("handle"+funcName+"(data, textStatus, jqXHR);");
                }
            }
        },
        error: function(data, textStatus, jqXHR) {
            if (data["responseText"].startsWith("<!DOCTYPE html>") && $.cookie('user_comp_code') !== undefined) {
                alert("세션이 만료되었습니다.\n잠시후 다시 시도해 주세요.");
                sessionStorage.setItem("user_comp_code", $.cookie('user_comp_code'));
                sessionStorage.setItem("user_id", $.cookie('user_id'));
            } else {
                var resJson = JSON.stringify(data["responseText"]);

                if(resJson && resJson["message"] !== 'undefined') {
                    notifyDanger(data["message"]);
                } else {
                    notifyDanger(LangData.get("서버 오류가 발생하였습니다."));
                }

                g_ShowResultMessageFlag = false;

                // http 오류(응답 코드가 200이 아닌 경우)
                if(eval("typeof(handleError"+funcName+")") == 'function') {
                    eval("handleError"+funcName+"(data, textStatus, jqXHR);");
                }
                
                form.removeData();
            }
            
        },
        dataType: dataType
    });
}

$(function() {

    // momentJS(날짜 처리 모듈) 언어셋을 한글로 변경
    moment.locale('ko');

    // ajax 요청 공통 셋업
    $.ajaxSetup({
        headers: {
            'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
        },
        beforeSend: function() {
            changeLoadingImageStatus(true);
        },
        complete: function() {
            //changeFixedContentsHeight();
            changeLoadingImageStatus(false);
            //tableScrollSync();
            if(typeof clearTime === "function") clearTime();
        },
        error: function() {
            g_StackLoadingImageStatus = 0;
            changeLoadingImageStatus(false);
        }
    });

    // jQueryNumericInput 이벤트 처리
    // 1. 포커스 되었을 시에는 콤마 없음
    // 2. 포커스 아웃 되었을 시에 콤마 처리
    // 3. 숫자가 아니면 빈값 처리
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

        // 아무 문자도 없다면 "" 이라고 세팅해 줌
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

        // 아무 문자도 없다면 "" 이라고 세팅해 줌
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

        // 아무 문자도 없다면 "" 이라고 세팅해 줌
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
        // $(this).select();
    }).on("focusout", "input[type='text'].jQueryNumericInputCheck", function(ev) {
        if($(this).prop("readonly") == true) {
            return true;
        }
        // 포커스 out 했을 때에 해당 값에 콤마를 찍어줌.
        $(this).val(addCommas($(this).val(), false));
    });

    // "전체" 체크박스 처리
    // data-checkbox="*_all", data-checkbox="*_item"
    $("body").on("click", "input[data-checkbox$='_checkall']", function() {
        // 전체 체크박스
        var obj = $(this);
        $("input[data-checkbox='" + obj.attr("name") + "_item']").prop("checked", obj.is(":checked"));
    }).on("click", "input[data-checkbox$='_item']", function() {
        // 나머지 체크박스
        var obj = $(this);
        if($("input[data-checkbox='" + obj.attr("name") + "_item']:checked").length == $("input[data-checkbox='" + obj.attr("name") + "_item']").length) {
            // 1. 모두 체크되어 있는 경우
            $("input[data-checkbox='" + obj.attr("name") + "_checkall']").prop("checked", true);
        } else {
            // 2. 하나라도 체크가 안되어 있는 경우
            $("input[data-checkbox='" + obj.attr("name") + "_checkall']").prop("checked", false);
        }
    });
    
    //자동완성
	$('.basicAutoComplete').each(function (idx, obj) {
		$(obj).autoComplete({
			resolver: 'custom',
			minLength: 0,
			events: {
				search: function (qry, callback) {
					var queryId = $(obj).data("query-id");
					var parentCodeId = "";
					
	                if (queryId.startsWith("#")) {
	                	queryId = "common.select_commCode";
	                	parentCodeId = queryId.substring(1).toUpperCase();
	                }
										
					const data = {
						"_token": $("meta[name='csrf-token']").prop("content"),
						"query_id": queryId,
						"parent_code_id": parentCodeId,
						"func": "IQ",
						"q": qry
					};
					const params = {
						"method": "POST",
						"data": data
					};
					
					setLoadImage(false);
					$.ajax('/walletfree-admin/common_autocomplete.do', params)
					.done(function (res) {
						//console.log(res);
						setLoadImage(true);
						
						if (res.q == qry) {
							callback(res.data);	
						}
					});
				}
			}
		});
		
		if($(obj).closest(".card-block").length > 0) {
			$(obj).closest(".card-block").css("overflow-y", "initial");
		}
	});

	$('.basicAutoComplete').on('change', function (e) {
		//console.log('change', $("#kClientName").val());

	});

	$('.basicAutoComplete').on('autocomplete.select', function (evt, item) {
		//console.log('select', $(this).data("code"));
		
		if ($(this).data("code")) {
			$("#" + $(this).data("code")).val(item.value);
			$("#" + $(this).data("code")).trigger("change");
		}
		
		$(this).val(item.name ? item.name : item.text);
	});

	$('.basicAutoComplete').on('autocomplete.freevalue', function (evt, value) {
		//console.log('freevalue', value, $(this).data("code"));
		
		if ($(this).data("code")) {
			$("#" + $(this).data("code")).val("");
		}
	});
	
});


(function($) {

    // $.fn.setLinkCombo = function() {
    //     var parentObj = $(this);

    //     parentObj.change(function() {
    //         var obj = $(this);
    //         // form_id = [string, jQuery selector] 서버로 데이터를 넘기기 위한 폼 객체
    //         // combo_target = [string, jQuery Selector] 변하게 될 element
    //         // combo_query = [string, query id] 변하게 될 element 에 들어갈 데이터의 쿼리
    //         // combo_elem = [string, jQuery Selector] 데이터에 추가적으로 넣을 파라미터
    //         // combo_param = {json} 추가적으로 들어갈 데이터의 키/값

    //         var combo_target = obj.getParam("combo_target");
    //         var combo_query = obj.getParam("combo_query");
    //         var combo_elem = obj.getParam("combo_elem");
    //         var combo_param = obj.getParam("combo_param");

    //     });
    // };

    /**
     * 범위 날짜를 바꿔준다. initDateOnly, initDateTime, initTimeOnly 처럼 daterangepicker 를 이용하여 초기화 한 객체만 가능함
     *
     * @param String p_StartDate 변경할 시작일자 (필수)
     * @param String p_EndDate 변경할 종료일자 (선택. 없으면 새로운 시작일자에 기존의 날짜 차이를 더한다.)
     *
     * @example 사용예제) $("#k_train_date").changePickerDate("2020-01-01"); ::: 시작일자를 2020년 1월 1일로 변경
     */
    $.fn.changeDateRange = function(p_StartDate, p_EndDate) {
        var obj = $(this);
        var not_init = typeof(obj.data('daterangepicker')) == 'undefined';

        if(not_init) {
            if(typeof(p_EndDate) != 'undefined') {
                obj.initDateOnly("days", 0, "days", 0);
            } else {
                obj.initDateOnly("days", 0);
            }
        }
        obj.data('daterangepicker').setStartDate(p_StartDate);

        // 종료 일자가 시작일자보다 이전인 경우 변경되지 않음
        if(typeof(p_EndDate) != 'undefined') {
            obj.data('daterangepicker').setEndDate(p_EndDate);
        } else {
            obj.data('daterangepicker').setEndDate(p_StartDate);
        }
    };

    // 년, 년월만 있는 달력 생성
    $.fn.initDateSingle = function(p_Type, p_Date) {
        p_Date = p_Date || (moment().format("YYYY-MM-DD"));
        p_Type = p_Type || "year";

        var obj = $(this);
        var locale_setting = rangeDatePickerLocaleSetting(false);
        var set_date;
        var viewMode = "";
        var format_string = ""

        if(p_Type == "year") {
            format_string = "yyyy";
            viewMode = "years";
            set_date = moment(p_Date.substring(0, 4) + "-" + moment().format("MM"));
        } else if(p_Type == "days") {
            format_string = "yyyy-mm-dd";
            viewMode = "days";
            set_date = moment(p_Date.substring(0, 4) + "-" + moment().format("MM") + "-" + moment().format("DD"));
        } else {
            format_string = "yyyy-mm";
            viewMode = "months";
            set_date = moment(p_Date);
        }

        obj.datepicker({
            language: "ko",
            minViewMode: viewMode,
            viewMode: viewMode,
            startView: viewMode,
            format: format_string,
            autoclose: true,
            orientation: "bottom",
            autoApply: true,
            onSelect: function(f,d,i){
                if(d !== i.lastVal){
                    $dateInput.trigger("change");
                }
            }
        }).css("text-align", "center");

        if(!obj.hasClass("fill")) {
            obj.addClass("fill");
        }

        obj.attr("data-daterangepicker", "date-single").attr("data-daterangepicker-type", p_Type).datepicker('update', p_Date);

        return this;
    };

    /**
     * 범위 달력 사용시 n달전 1일부터 오늘까지를 기본값으로 설정해 주는 함수
     *
     * @param number p_Diff 현재로부터 몇 달 전까지를 표시할지 결정 (기본값: 0, 이번달)
     *
     * @returns this object
     */
    $.fn.initDateRangeMonthly = function(p_Diff) {
        var obj = $(this);
        var locale_setting = rangeDatePickerLocaleSetting(false);
        var today = moment();
        var start_date = moment();

        start_date = moment(today.format("YYYY") + "-" + today.format("MM") + "-01").add(p_Diff * (-1), "month");

        var dateSetting = {
            "locale": locale_setting,
            "autoApply": true,
            "linkedCalendars": false,
            "showCustomRangeLabel": false,
            "showDropdowns": true,
            "timePicker": false,
            "singleDatePicker": false,
            "startDate": start_date.format("YYYY-MM-DD"),
            "endDate": today.format("YYYY-MM-DD")
        }

        obj.daterangepicker(dateSetting).css("text-align", "center");

        if(!obj.hasClass("fill")) {
            obj.addClass("fill");
        }

        obj.attr("data-daterangepicker", "date-only-range");

        return this;
    };

    /**
     * 범위 달력 사용시 금일이 포함된 월/주를 기본값으로 설정해 주는 함수.
     * 예) 저번달 1일 ~ 이번달 말일, 저번주 일요일 ~ 다음주 월요일
     *
     * @param String p_Mode 월단위(month, 기본값), 주단위(week) 를 결정
     * @param number p_StartDiff 현재 월/주 에서 얼마나 이전까지를 표시할지 결정 (0:이번달/주(기본값), 1:지난달/주, ...)
     * @param number p_EndDiff 현재 월/주 에서 얼마나 이후까지를 표시할지 결정 (0:이번달/주(기본값), 1:다음달/주, ...)
     */
    $.fn.initDateRange = function(p_Mode, p_StartDiff, p_EndDiff) {
        // p_Mode = "month"(기본값), "week"
        var obj = $(this);
        var locale_setting = rangeDatePickerLocaleSetting(false);
        var today = moment();
        var start_date = moment();
        var end_date = moment();

        p_Mode = p_Mode || "month";
        p_StartDiff = typeof(p_StartDiff) != 'number' ? 0 : p_StartDiff;
        p_EndDiff = typeof(p_EndDiff) != 'number' ? 0 : p_EndDiff;

        if(p_Mode == "month") {
            start_date = moment(today.format("YYYY") + "-" + today.format("MM") + "-01").add(p_StartDiff * (-1), "month");
            end_date = moment(today.format("YYYY") + "-" + today.format("MM") + "-01").add(p_EndDiff + 1, "month").add(-1, "day");
        } else if(p_Mode == "week") {
            // 월요일인 경우 월요일=2 이기 때문에 하루를 빼서 일요일로 만들어줌
            // 이후 몇 주전까지 표시할 지를 계산하여 처리함
            start_date = start_date.add((parseInt(today.format("E"), 10) - 1) * (-1), "day").add((-1) * p_StartDiff * 7, "day");
            end_date = end_date.add((7 - parseInt(today.format("E"), 10)), "day").add(p_EndDiff * 7, "day");
        }

        var dateSetting = {
            "locale": locale_setting,
            "autoApply": true,
            "linkedCalendars": false,
            "showCustomRangeLabel": false,
            "showDropdowns": true,
            "timePicker": false,
            "singleDatePicker": false,
            "startDate": start_date.format("YYYY-MM-DD"),
            "endDate": end_date.format("YYYY-MM-DD")
        }

        obj.daterangepicker(dateSetting).css("text-align", "center");

        if(!obj.hasClass("fill")) {
            obj.addClass("fill");
        }

        obj.attr("data-daterangepicker", "date-only-range");

        return this;
    };

    /**
     * 범위 날짜를 하나의 텍스트박스에 세팅하기 위한 함수 (시간 없음)
     * p_EndUnit, p_EndDiff 가 없는 경우 (typeof() == 'undefined') Ranged 가 아닌 Single Datepicker 로 세팅된다.
     * @param {String} p_StartUnit "days", "months", "years" 중 하나
     * @param {number} p_StartDiff (시작 일자)오늘 날짜에서 p_StartUnit 에 지정한 일/월/년 만큼 더하거나 뺌
     * @param {String} p_EndUnit "days", "months", "years" 중 하나
     * @param {Number} p_EndDiff (종료 일자)오늘 날짜에서 p_EndUnit 에 지정한 일/월/년 만큼 더하거나 뺌
     */
    $.fn.initDateOnly = function(p_StartUnit, p_StartDiff, p_EndUnit, p_EndDiff) {
        var obj = $(this);
        var locale_setting = rangeDatePickerLocaleSetting(false);
        var isSinglePicker = arguments.length < 4;
        var start_date = moment();
        var end_date = moment();
        var start_unit = "";
        var end_unit = "";

        if(typeof(p_StartUnit) != 'undefined') {
            switch(p_StartUnit.toLowerCase()) {
                case "d": start_unit = "days"; break;
                case "m": start_unit = "months"; break;
                case "y": start_unit = "hours"; break;
                default: start_unit = p_StartUnit;
            }
        } else {
            start_unit = "days";
        }

        if(typeof(p_EndUnit) != 'undefined') {
            switch(p_EndUnit.toLowerCase()) {
                case "d": end_unit = "days"; break;
                case "m": end_unit = "months"; break;
                case "y": end_unit = "hours"; break;
                default: end_unit = p_EndUnit;
            }
        } else {
            end_unit = "days";
        }

        if(arguments.length < 2) {
            // 시작/종료일자는 금일로 처리
        } else if(arguments.length >= 2 && arguments.length < 4) {
            // 시작 일자만 계산 처리
            start_date = start_date.add(p_StartDiff, start_unit);
        } else {
            start_date = start_date.add(p_StartDiff, start_unit);
            end_date = end_date.add(p_EndDiff, end_unit);

            if(start_date > end_date) {
                var tmp_date = start_date;
                start_date = end_date;
                end_date = tmp_date;
            }
        }

        var dateSetting = {
            locale: locale_setting,
            "autoApply": true,
            "linkedCalendars": false,
            "showCustomRangeLabel": false,
            "showDropdowns": true,
            "timePicker": false,
            "singleDatePicker": isSinglePicker,
            "startDate": start_date.format("YYYY-MM-DD"),
        }

        if(!isSinglePicker) {
            dateSetting["endDate"] = end_date.format("YYYY-MM-DD");
        }

        obj.daterangepicker(dateSetting).css("text-align", "center");

        if(!obj.hasClass("fill")) {
            obj.addClass("fill");
        }

        obj.attr("data-daterangepicker", "date-only");
    }

    /**
     * 범위 날짜를 하나의 텍스트박스에 세팅하기 위한 함수 (시간 없음)
     * p_EndUnit, p_EndDiff 가 없는 경우 (typeof() == 'undefined') Ranged 가 아닌 Single Datepicker 로 세팅된다.
     * @param {String} p_StartUnit "days", "months", "years" 중 하나
     * @param {number} p_StartDiff (시작 일자)오늘 날짜에서 p_StartUnit 에 지정한 일/월/년 만큼 더하거나 뺌
     * @param {String} p_EndUnit "days", "months", "years" 중 하나
     * @param {Number} p_EndDiff (종료 일자)오늘 날짜에서 p_EndUnit 에 지정한 일/월/년 만큼 더하거나 뺌
     */
    $.fn.initDateTime = function(p_StartUnit, p_StartDiff, p_EndUnit, p_EndDiff) {
        var obj = $(this);
        var locale_setting = rangeDatePickerLocaleSetting(true);
        var isSinglePicker = arguments.length < 4;
        var start_date = moment();
        var end_date = moment();
        var start_unit = "";
        var end_unit = "";

        if(typeof(p_StartUnit) != 'undefined') {
            switch(p_StartUnit.toLowerCase()) {
                case "d": start_unit = "days"; break;
                case "m": start_unit = "months"; break;
                case "y": start_unit = "hours"; break;
                default: start_unit = p_StartUnit;
            }
        } else {
            start_unit = "days";
        }

        if(typeof(p_EndUnit) != 'undefined') {
            switch(p_EndUnit.toLowerCase()) {
                case "d": end_unit = "days"; break;
                case "m": end_unit = "months"; break;
                case "y": end_unit = "hours"; break;
                default: end_unit = p_EndUnit;
            }
        } else {
            end_unit = "days";
        }

        if(arguments.length < 2) {
            // 시작/종료일자는 금일로 처리
        } else if(arguments.length >= 2 && arguments.length < 4) {
            // 시작 일자만 계산 처리
            start_date = start_date.add(p_StartDiff, start_unit);
        } else {
            start_date = start_date.add(p_StartDiff, start_unit);
            end_date = end_date.add(p_EndDiff, end_unit);

            if(start_date > end_date) {
                var tmp_date = start_date;
                start_date = end_date;
                end_date = tmp_date;
            }
        }

        obj.daterangepicker({
            locale: locale_setting,
            "autoApply": true,
            "linkedCalendars": false,
            "showCustomRangeLabel": false,
            "showDropdowns": true,
            "timePicker": true,
            "timePicker24Hour": true,
            "timePickerIncrement": 5,
            "singleDatePicker": isSinglePicker,
            "startDate": start_date.format("YYYY-MM-DD"),
            "endDate": end_date.format("YYYY-MM-DD"),
        }).css("text-align", "center");

        if(!obj.hasClass("fill")) {
            obj.addClass("fill");
        }

        obj.attr("data-daterangepicker", "date-time");
    }

    $.fn.initTimeOnly = function(p_StartTime, p_EndTime) {
        var obj = $(this);

        var start_date = "";
        var end_date = "";

        var isSinglePicker = false;

        if(arguments.length < 1) {
            start_date = moment(moment().format("YYYY-MM-DD") + " 00:00:00");
            end_date = moment(moment().format("YYYY-MM-DD") + " 23:55:00");
            isSinglePicker = true;
        } else if(arguments.length == 1) {
            start_date = moment(moment().format("YYYY-MM-DD") + " " + p_StartTime + ":00");
            end_date = moment(moment().format("YYYY-MM-DD") + " 23:55:00");
            isSinglePicker = true;
        } else {
            start_date = moment(moment().format("YYYY-MM-DD") + " " + p_StartTime + ":00");
            end_date = moment(moment().format("YYYY-MM-DD") + " " + p_EndTime + ":00");
            isSinglePicker = false;
        }

        obj.daterangepicker({
            timePicker : true,
            timePicker24Hour : true,
            timePickerIncrement : 5,
            timePickerSeconds : true,
            singleDatePicker: isSinglePicker,
            startDate: start_date,
            endDate: end_date,
            locale : { 
                format : 'HH : mm : ss'
            } 
        }).on('show.daterangepicker', function(ev, picker) {
            picker.container.find(".calendar-table").hide();
        }).css("text-align", "center");

        if(!obj.hasClass("fill")) {
            obj.addClass("fill");
        }

        obj.attr("data-daterangepicker", "time-only");
    }

    // 그리드의 모든 데이터를 폼에 세팅하는 함수
    $.fn.gridDataAll = function(_gridOptions){
        var obj = $(this);
        var params = {};
        var dataCount = 0;

        _gridOptions.api.forEachNode( function(node) {
            for(v in node.data){
                if(typeof(params["grd_" + v + "[]"]) == 'undefined') {
                    params["grd_" + v + "[]"] = [];
                }

                params["grd_" + v + "[]"].push(node.data[v]);
            }
            dataCount++;
        });

        for(var s in params) {
            obj.addParam(s, params[s]);
        }

        return dataCount;
    };

    // 특정 그리드에 있는 선택된 데이터를 폼에 세팅하는 함수
    $.fn.gridDataSelected = function(_gridOptions) {
        var obj = $(this);
        var params = [];
        var dataCount = 0;

        for(var i = 0; i < _gridOptions.api.getSelectedNodes().length; i++) {
            params.push(_gridOptions.api.getSelectedNodes()[i].data);
            dataCount++;
        }

        var result = {};

        for(var i = 0; i < params.length; i++) {
            for(var s in params[i]) {
                if(typeof(result["grd_" + s + "[]"]) == 'undefined') {
                    result["grd_" + s + "[]"] = [];
                }

                result["grd_" + s + "[]"].push(params[i][s]);
            }
        }

        for(var p in result) {
            obj.addParam(p, result[p]);
        }

        return dataCount;
    };

    // 특정 그리드에 있는 데이터 중 조건에 맞는 데이터를 세팅해 주는 함수
    // 조건 : 추가/수정/삭제 등이 일어난 row. (state_col != "")
    $.fn.gridStateChanged = function(_gridOptions){
        var obj = $(this);
        var params = {};
        var dataCount = 0;

        _gridOptions.api.forEachNode( function(node) {
            if(typeof(node.data["state_col"]) != 'undefined' && node.data["state_col"] != null && node.data["state_col"] != "") {
                for(v in node.data){
                    if(typeof(params["grd_" + v + "[]"]) == 'undefined') {
                        params["grd_" + v + "[]"] = [];
                    }

                    params["grd_" + v + "[]"].push(node.data[v]);
                }

                dataCount++;
            }
        });

        for(var s in params) {
            obj.addParam(s, params[s]);
        }

        return dataCount;
    };

    // 그리드의 모든 데이터를 리턴하는 함수
    $.fn.getGridDataAll = function(_gridOptions) {
        var params = {};

        _gridOptions.api.forEachNode( function(node) {
            for(v in node.data){
                if(typeof(params["grd_" + v + "[]"]) == 'undefined') {
                    params["grd_" + v + "[]"] = [];
                }

                params["grd_" + v + "[]"].push(node.data[v]);
            }
        });

        return params;
    };

    // 특정 그리드에 있는 선택된 데이터를 리턴하는 함수
    $.fn.getGridDataSelected = function(_gridOptions) {
        var params = [];

        for(var i = 0; i < _gridOptions.api.getSelectedNodes().length; i++) {
            params.push(_gridOptions.api.getSelectedNodes()[i].data);
        }

        var result = {};

        for(var i = 0; i < params.length; i++) {
            for(var s in params[i]) {
                if(typeof(result["grd_" + s + "[]"]) == 'undefined') {
                    result["grd_" + s + "[]"] = [];
                }

                result["grd_" + s + "[]"].push(params[i][s]);
            }
        }

        return result;
    };

    // 특정 그리드에 있는 데이터 중 조건에 맞는 데이터를 리턴하는 함수
    // 조건 : 추가/수정/삭제 등이 일어난 row. (state_col != "")
    $.fn.getGridStateChanged = function(_gridOptions) {
        var params = {};

        _gridOptions.api.forEachNode( function(node) {
            if(typeof(node.data["state_col"]) != 'undefined' && node.data["state_col"] != null && node.data["state_col"] != "") {
                for(v in node.data){
                    if(typeof(params["grd_" + v + "[]"]) == 'undefined') {
                        params["grd_" + v + "[]"] = [];
                    }

                    params["grd_" + v + "[]"].push(node.data[v]);
                }
            }
        });

        return params;
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

    $.fn.addInput = function(keyStr, valueStr) {
        var obj = $(this)[0];

        if ($(this).find("input[name='"+keyStr+"']").length == 0) {
        	$(this).append("<input type='hidden' id='"+keyStr+"' name='"+keyStr+"' value='"+valueStr+"' />");
        } else {
        	$(this).find("input[name='"+keyStr+"']").val(valueStr);
        }
    };

    $.fn.request = function() {
        var obj = $(this);
        var obj_id = $(this).attr("id");
        var funcName = obj.getParam("func") || "";
        var result = obj.getParam("result") || "";
        var dataType = obj.getParam("dataType") || "";
        // method 가 없으면 prop 로 가져오는 경우 "get" 문자열을 갖고 오기 때문에 실제 method 속성이 있는지 알려면 attr 로 가지고 와야 함
        var methodType = obj.attr("method") || "post";
        var grid_init = obj.getParam("grid") || "";
        var baseData = obj.getParam("baseData");
        var afterAction;
        // 필수 필드에 값을 넣지 않았을 때의 기본 action 사용 여부
        var reqAction;
        // 필수 필드에 값을 넣지 않았을 때 사용할 추가 동작 함수
        var reqFunc = typeof(obj.getParam("reqFunc") == 'function') ? obj.getParam("reqFunc") : null;
        // Ajax Type
        var ajaxType = obj.getParam("ajaxType") || "";

        var grid_ary = grid_init.split(".");
        var grid = grid_ary[0];
        var grid_ins_data_option = grid_ary.length > 1 ? grid_ary[1].toLowerCase() : "state_col"; // "all", "check", "nocheck", "state_col" (default)
        
        var useChunk = false; // Chunk 로 데이터를 잘라서 보낼지 아니면 그냥 보낼지를 저장하는 내부 변수 (그리드 데이터가 있어도 개수가 작으면 그냥 보내도록 하기 위함)
        var eachDataCount = __g_EachRepeatCount; // 그리드 데이터 전송시 한 번에 몇 개까지 데이터를 전송하는지 저장하기 위한 변수 --> DB에서 받아올 수 있도록.. (__g_EachRepeatCount 는 src의 query string 에서 받아온 값)
        var requestTotalCount = 0; // 그리드에서 전송할 전체 데이터 개수
        var requestStIdx = 0; // 시작 인덱스 (현재 전송중인 데이터)
        var requestFnIdx = 0; // 종료 인덱스 (현재 전송중인 데이터)
        var allGridData = {}; // 전송할 그리드의 데이터를 모두 저장
        var actualUrl = ""; // 실제 전송할 URL을 설정
        var chunkUuid = getUuidV4(); // DB에 저장하기 위한 키
        var requestCount = 0; // 몇 번째 요청인지를 저장
        var useChunkDataUpload = obj.getParam("useChunkDataUpload"); // 화면에서 전송한 Chunk upload 를 사용할지의 여부 (false: 무조건 미사용(기본값) / true: 조건에 따라 사용)
        
        useChunkDataUpload = (useChunkDataUpload === true); // 파라미터값이 true(boolean)가 아니면 무조건 false 처리

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

        if(typeof(obj.getParam("reqAction")) == "boolean") {
            reqAction = obj.getParam("reqAction");
        } else if(typeof(obj.getParam("reqAction")) != "undefined") {
            if(obj.getParam("reqAction") == "") {
                reqAction = true;
            }
        } else {
            reqAction = true;
        }

        var resultid = "";

        obj.addParam("obj_id", obj_id);

        if(result != ""){
            resultid = result.attr("id");
        }

        // obj.addParam("result_id", resultid);

        var objAction = obj.getParam("setAction") || false;

        if(funcName.startsWith("IQ")){
            obj.serializeArrayCustom();
            if(!objAction){
                if(dataType == "json"){
                    //obj.setAction("/sdm/source/CS/common_table_json.php");
                    obj.setAction("/walletfree-admin/common_select.do");
                }
                else{
                    obj.setAction("/walletfree-admin/common_select.do");
                }
            }
        }
        else if(funcName.startsWith("IS") || funcName.startsWith("MD") || funcName.startsWith("DL")){
            if(!objAction){
                obj.setAction("/walletfree-admin/common_insert.do");
            }

            var check_result = [];
            if(grid != "") {
                var gridObj = eval(grid);
                check_result = gridObj.checkValue();

                if(!check_result["input_ok"]) {

                    // 필수 필드 기본동작
                    if(reqAction) {
                        gridObj.api.startEditingCell({
                            rowIndex: check_result['req_row'],
                            colKey: check_result['req_column']
                        });
                        notifyDanger(PageLang.msg("noReqValue"));
                    }

                    if(reqFunc != "") {
                        reqFunc.call(null, check_result['req_row'], check_result['req_column']);
                    }

                    obj.removeData();

                    return;
                }

                if(grid_ins_data_option == "all") {
                    // 전체 데이터 넘김
                    allGridData = obj.getGridDataAll(gridObj);
                    if(Object.keys(allGridData).length < 1) {
                        notifyDanger("변경된 행이 없습니다.");
                        obj.removeData();
                        return;
                    };
                } else if(grid_ins_data_option == "check") {
                    // 체크 데이터 넘김 - 미구현
                    allGridData = obj.getGridDataSelected(gridObj);
                    if(Object.keys(allGridData).length < 1) {
                        notifyDanger("변경된 행이 없습니다.");
                        obj.removeData();
                        return;
                    };
                } else if(grid_ins_data_option == "nocheck") {
                    // 미체크 데이터 넘김 - 미구현
                    allGridData = obj.getGridDataAll(gridObj);
                    if(Object.keys(allGridData).length < 1) {
                        notifyDanger("변경된 행이 없습니다.");
                        obj.removeData();
                        return;
                    };
                } else if(grid_ins_data_option == "state_col") {
                    // 구분 컬럼(상태값)에 값이 있는 row 만 넘김
                    allGridData = obj.getGridStateChanged(gridObj);
                    if(Object.keys(allGridData).length < 1) {
                        notifyDanger("변경된 행이 없습니다.");
                        obj.removeData();
                        return;
                    };
                }
            }
        }

        if(dataType == ""){
            obj.addParam("dataType","json");
            dataType = "json";
        }

        obj.removeData("setAction");
        obj.removeData("result");

        if(ajaxType == "file") {
            $.each(jQuery.data(obj[0]), function(k, v) {
                if($(obj[0]).find("[name='" + k + "']").length < 1) {
                    if(jQuery.isArray(v)) {
                        $.each(v, function(a, b) {
                            $(obj[0]).append($('<input type="hidden" name="' + k + '" value="' + b + '" />'));
                        });
                    } else {
                        $(obj[0]).append($('<input type="hidden" name="' + k + '" value="' + v + '" />'));
                    }
                }
            });
        }

        // 파일 업로드가 아니고 그리드 데이터가 존재하는 경우
        if(Object.keys(allGridData).length > 0 && ajaxType != "file") {
            if(useChunkDataUpload) {
                requestTotalCount = allGridData[Object.keys(allGridData)[0]].length; // 전체 데이터 개수 세팅
                requestStIdx = 0; // 시작 인덱스
                requestFnIdx = requestStIdx + (eachDataCount - 1); // 종료 인덱스
                // 최대 개수가 넘으면 마지막 인덱스를 가리키도록 처리
                requestFnIdx = requestFnIdx > requestTotalCount - 1 ? requestTotalCount - 1 : requestFnIdx;
                // 만약 총 데이터 개수가 1회 전송하는 개수보다 많으면 chunk 전송 처리
                useChunk = requestTotalCount > eachDataCount;
            }
            
            if(useChunk) {
                requestStIdx = -1; // 요청 전에 계산하므로 -1을 기본값으로 줘야 함
                requestFnIdx = -1; // 요청 전에 계산하므로 -1을 기본값으로 줘야 함
                
                let reqCont = {};
    
                // 기타 데이터 추가
                obj.addParam("originUrl", obj.prop("action"));           // 로직이 처리되는 URL
                obj.addParam("requestDataCount", 0);                     // 실제 추가된 데이터 개수 (최초이므로 0)
                obj.addParam("eachDataCount", eachDataCount);            // 1회 전송시 보내는 최대 개수
                obj.addParam("requestTotalCount", requestTotalCount);    // 전체 데이터 개수
                obj.addParam("requestStIdx", requestStIdx);              // 전송 중인 데이터의 시작 인덱스
                obj.addParam("requestFnIdx", requestFnIdx);              // 전송 중인 데이터의 종료 인덱스
                obj.addParam("chunkUuid", chunkUuid);                    // 키값 전송
                obj.addParam("requestCount", (++requestCount));          // 요청 횟수 추가 후 전송(1이 최초 전송)
                obj.addParam("requestDataType", "RDT001");               // RDT001: 단일 데이터(첫 전송만 사용), RDT002: 그리드 데이터(2회차부터 그리드 데이터 전송)
                
                for(let k in obj.data()) {
                    if(k != "requestContents") {
                        reqCont[k] = obj.data()[k];
                    }
                }
                
                obj.addParam("requestContents", JSON.stringify(reqCont));  // 요청하는 모든 데이터를 JSON 으로 변환하여 전송
            } else {
                // chunk 를 사용하지 않고 그리드 데이터가 있다면 해당 데이터를 form 에 추가
                if(grid_ins_data_option == "all") {
                    // 전체 데이터 넘김
                    obj.gridDataAll(gridObj);
                } else if(grid_ins_data_option == "check") {
                    // 체크 데이터 넘김 - 미구현
                    obj.gridDataSelected(gridObj);
                } else if(grid_ins_data_option == "nocheck") {
                    // 미체크 데이터 넘김 - 미구현
                    obj.gridDataAll(gridObj);
                } else if(grid_ins_data_option == "state_col") {
                    // 구분 컬럼(상태값)에 값이 있는 row 만 넘김
                    obj.gridStateChanged(gridObj);
                }
            }
        }

        // chunk 를 사용하면 특정 URL로 보내고, 아니면 원래 URL 로 보내도록 변수를 변경
        actualUrl = useChunk ? "/walletfree-admin/upload/dataChunkProcess.do" : obj.prop("action");

        // 전송할 데이터
        var send_data = ajaxType == "file" ? new FormData(obj[0]) : jQuery.data(obj[0]);
        // 토큰값 추가 (layout 에 있음)
        send_data["_token"] = $("meta[name='csrf-token']").prop("content");

        // 최초 데이터 전송
        $.ajax({
            method: methodType,
            url: actualUrl,
            data: send_data,
            contentType : ajaxType == "file" ? false : "application/x-www-form-urlencoded; charset=UTF-8",
            processData : ajaxType == "file" ? false : true,
            success : function(data, textStatus, jqXHR) {

                if(useChunkDataUpload && useChunk) {
                    // Chunk 사용시 다음 전송이 필요함
                    if(data["count"] > 0) {
                        requestNextData(obj, chunkUuid, allGridData, obj.prop("action"), actualUrl, send_data, eachDataCount, requestTotalCount, requestStIdx, requestFnIdx, methodType, ajaxType, grid, funcName, baseData, resultid, afterAction, dataType, requestCount + 1);
                    } else {
                        // 오류를 리턴한 경우 중지
                        notifyDanger(data["message"]);
                    }
                } else {
                    // Chunk 미사용시 일반적인 데이터 처리
                    changeLoadingImageStatus(false);

                    if(grid != "" && funcName.startsWith("IQ")){
                        eval(grid + ".api.setRowData(JSON.parse(JSON.stringify(data)));");
                        eval(grid + ".setOriginalData(JSON.parse(JSON.stringify(data)));");

                        if(baseData != ""){
                            eval(baseData +"= JSON.parse(JSON.stringify(data));");
                        }

                        setGridHeight(resultid);

                        // g_StackLoadingImageStatus : in common.js
                        if(afterAction && g_ShowResultMessageFlag) {
                            notifyInfo("조회가 완료되었습니다.");
                            g_ShowResultMessageFlag = false;
                        }

                    } else if(funcName.startsWith("ID")) {
                        if(afterAction && g_ShowResultMessageFlag) {
                            if(data["count"] > 0) {
                                notifyInfo(data["message"]);
                            } else {
                                notifyDanger(data["message"]);
                            }
                            g_ShowResultMessageFlag = false;
                        }
                    } else if(funcName.startsWith("IS")) {
                        if(afterAction && g_ShowResultMessageFlag) {
                            if(data["count"] > 0) {
                                notifyInfo(data["message"]);
                            } else {
                                notifyDanger(data["message"]);
                            }
                            g_ShowResultMessageFlag = false;
                        }
                    } else if(funcName.startsWith("DL")) {
                        if(afterAction && g_ShowResultMessageFlag) {
                            if(data["count"] > 0) {
                                notifyInfo(data["message"]);
                            } else {
                                notifyDanger(data["message"]);
                            }
                            g_ShowResultMessageFlag = false;
                        }
                    } else if(funcName.startsWith("MD")) {
                        if(afterAction && g_ShowResultMessageFlag) {
                            if(data["count"] > 0) {
                                notifyInfo(data["message"]);
                            } else {
                                notifyDanger(data["message"]);
                            }
                            g_ShowResultMessageFlag = false;
                        }
                    }

                    obj.removeData();

                    // 정상 종료인 경우
                    if(eval("typeof(handleOK"+funcName+")") == 'function' && data["count"] > 0) {
                        eval("handleOK"+funcName+"(data, textStatus, jqXHR);");
                    }

                    // http 응답 코드가 200이지만, 내부적으로 오류로 판단한 경우
                    if(eval("typeof(handleNO"+funcName+")") == 'function' && data["count"] <= 0) {
                        eval("handleNO"+funcName+"(data, textStatus, jqXHR);");
                    }

                    // 앞의 두 가지 처리 후 마지막으로 공통 처리
                    if(eval("typeof(handle"+funcName+")") == 'function') {
                        eval("handle"+funcName+"(data, textStatus, jqXHR);");
                    }
                }
            },
            error: function(data, textStatus, jqXHR) {
                if (data["responseText"].startsWith("<!DOCTYPE html>") && $.cookie('user_comp_code') !== undefined) {
                	alert("세션이 만료되었습니다.\n잠시후 다시 시도해 주세요.");
                	sessionStorage.setItem("user_comp_code", $.cookie('user_comp_code'));
                	sessionStorage.setItem("user_id", $.cookie('user_id'));
                } else {
                	var resJson = JSON.stringify(data["responseText"]);

                    if(resJson && resJson["message"] !== 'undefined') {
                        notifyDanger(data["message"]);
                    } else {
                        notifyDanger(LangData.get("서버 오류가 발생하였습니다."));
                    }

                    g_ShowResultMessageFlag = false;

                    // http 오류(응답 코드가 200이 아닌 경우)
                    if(eval("typeof(handleError"+funcName+")") == 'function') {
                        eval("handleError"+funcName+"(data, textStatus, jqXHR);");
                    }
                    
                    obj.removeData();
                }
                
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
            
            // sumoselect 플러그인(멀티셀렉트) 적용된건 찾지 않도록 함
            if(elemObj.hasClass("SumoUnder")) {
                return false;
            }

            if(typeof(elemObj.data("inputMasking")) != 'undefined') {
                obj.addParam(elemObj.attr("name"), elemObj.data("inputMasking").getValue());
            } else if(elemObj[0].tagName.toLowerCase() == "input") {
                if(elemObj.attr("type") == "text" || elemObj.attr("type") == "hidden"){
                    if(typeof(elemObj.attr("name")) == "undefined"){
                        console.log("name 속성을 찾을 수 없습니다.");
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
                            console.log("name 속성을 찾을 수 없습니다.");
                            return false;
                        }
                        obj.addParam(elemObj.attr("name"), elemObj.val());
                    }
                }else if(elemObj.attr("type") == "checkbox"){
                    if(elemObj.is(":checked")){
                        if(typeof(elemObj.attr("name")) == "undefined"){
                            console.log("name 속성을 찾을 수 없습니다.");
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
                    console.log("name 속성을 찾을 수 없습니다.");
                    return false;
                }
                obj.addParam(elemObj.attr("name"), elemObj.val());
            }else if(elemObj[0].tagName.toLowerCase() == "select") {
                if(typeof(elemObj.attr("name")) == "undefined"){
                    console.log("name 속성을 찾을 수 없습니다.");
                    return false;
                }
                obj.addParam(elemObj.attr("name"), elemObj.val());
            }
        });

        for(var item in chkValue){
            obj.addParam(item, chkValue[item]);
        }
    };

    $.fn.hrefPost = function(_url) {
        var frmId = "hrefPost_" + Math.round(Math.random() * 1000000, 0);
        var obj = $(this);
        var elemObj;
        var chkValue = {};

        $("body").append('<form id="' + frmId + '" method="POST" action="' + _url + '"></form>');
        $("#" + frmId).append('<input type="hidden" name="_token" value="' + $("meta[name='csrf-token']").attr("content") + '" />');

        $("#" + obj.attr("id") + " *").each(function(idx, elem) {
            elemObj = $(elem);

            if(elemObj[0].tagName.toLowerCase() == "input") {
                if(elemObj.attr("type") == "text" || elemObj.attr("type") == "hidden"){
                    if(typeof(elemObj.attr("name")) == "undefined"){
                        console.log("name 속성을 찾을 수 없습니다.");
                        return false;
                    }

                    $("#" + frmId).append('<input type="hidden" name="' + elemObj.attr("name") + '" value="' + elemObj.val() + '" />');
                }else if(elemObj.attr("type") == "radio"){
                    if(elemObj.is(":checked")){
                        if(typeof(elemObj.attr("name")) == "undefined"){
                            console.log("name 속성을 찾을 수 없습니다.");
                            return false;
                        }
                        $("#" + frmId).append('<input type="hidden" name="' + elemObj.attr("name") + '" value="' + elemObj.val() + '" />');
                    }
                }else if(elemObj.attr("type") == "checkbox"){
                    if(elemObj.is(":checked")){
                        if(typeof(elemObj.attr("name")) == "undefined"){
                            console.log("name 속성을 찾을 수 없습니다.");
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
                    console.log("name 속성을 찾을 수 없습니다.");
                    return false;
                }
                $("#" + frmId).append('<input type="hidden" name="' + elemObj.attr("name") + '" value="' + elemObj.val() + '" />');
            }else if(elemObj[0].tagName.toLowerCase() == "select") {
                if(typeof(elemObj.attr("name")) == "undefined"){
                    console.log("name 속성을 찾을 수 없습니다.");
                    return false;
                }
                $("#" + frmId).append('<input type="hidden" name="' + elemObj.attr("name") + '" value="' + elemObj.val() + '" />');
            }
        });

        for(var item in chkValue){
            $("#" + frmId).append('<input type="hidden" name="' + item + '" value="' + chkValue[item] + '" />');
        }

        $("#" + frmId).submit();
    };

    $.fn.autoSearch = function(funcSearch) {
        var obj = $(this);

        // select box 자동조회
        $("#" + obj.attr("id") + " select").not("[data-not-search]").each(function(idx, elem) {
            $(elem).change(function(ev){
                if($("button[data-cell_edit='disabled']").length > 0) {
                    ev.preventDefault();
                    notifyDanger("name 속성을 찾을 수 없습니다.");
                    return false;
                } else {
                    funcSearch.call(1);
                }
            });
        });

        // input type="text" 자동조회
        $("#" + obj.attr("id") + " input:text").not("[data-not-search]").each(function(idx, elem) {
        	if ($(this).hasClass("basicAutoComplete")) return;
        	
            $(elem).keyup(function(ev){
                if(ev.keyCode == 13 && $(this).attr("type") != 'textarea'){
                    if($("button[data-cell_edit='disabled']").length > 0) {
                        notifyDanger("name 속성을 찾을 수 없습니다.");
                    } else {
                        funcSearch.call(1);
                    }
                }
            });
        });

        // 체크박스 자동조회
        $("#" + obj.attr("id") + " input[type='checkbox']").not("[data-not-search]").each(function(idx, elem) {
            $(elem).change(function(ev){
                if($("button[data-cell_edit='disabled']").length > 0) {
                    notifyDanger("name 속성을 찾을 수 없습니다.");
                } else {
                    funcSearch.call(1);
                }
            });
        });

        // 라디오버튼 자동조회
        $("#" + obj.attr("id") + " input[type='radio']").not("[data-not-search]").each(function(idx, elem) {
            $(elem).change(function(ev){
                if($("button[data-cell_edit='disabled']").length > 0) {
                    notifyDanger("name 속성을 찾을 수 없습니다.");
                } else {
                    funcSearch.call(1);
                }
            });
        });

        // daterangepicker 자동조회
        $("#" + obj.attr("id") + " input[data-daterangepicker]").not("[data-not-search]").each(function(idx, elem) {
            $(elem).on("apply.daterangepicker", function(ev, picker) {
                if($("button[data-cell_edit='disabled']").length > 0) {
                    notifyDanger("name 속성을 찾을 수 없습니다.");
                } else {
                    funcSearch.call(1);
                }
            });
        });  
        
		$('.basicAutoComplete').not("[data-not-search]").on('autocomplete.select', function (evt, item) {
            funcSearch.call(1);
		});

		$('.basicAutoComplete').not("[data-not-search]").on('autocomplete.freevalue', function (evt, value) {
            funcSearch.call(1);
		});
    };

    // full calendar 모듈
    // 1. 셀렉터
    // 2. 캘린더 데이터 select query id
    // 3. 최초 로딩 후에 보여줄 일자
    // 4. 편집 가능 여부
    // 5. 일반 조회 후에 수행할 함수
    // 6. 일정을 드래그 & 드랍한 후에 수행할 함수
    // 7. 시간을 보여줄지를 결정 (기본은 false)
    // 8. 날짜 자체를 클릭한 후의 함수
    // 9. 일정 클릭 함수
    // 10. 일정을 늘리거나 줄인 후의 함수
    // 11. 추가 파라미터
    $.fn.setFullCalendar = function(p_Selector, p_QueryId, p_DefaultDate, p_Editable, p_CallbackFunction, p_UpdateFunction, p_ShowTime, p_ClickFunction, p_EventClickFunction, p_ResizeFunction, p_Params) {

        p_DefaultDate = p_DefaultDate || moment.format("YYYY-MM-DD");
        p_UpdateFunction = p_UpdateFunction || function() {};
        p_ClickFunction = p_ClickFunction || function() {};
        p_EventClickFunction = p_EventClickFunction || function() {};
        p_ResizeFunction = p_ResizeFunction || function() {};
        p_CallbackFunction = p_CallbackFunction || function() {};
        // p_MultiSelectFunction = p_MultiSelectFunction || function() {};
        p_ShowTime = typeof(p_ShowTime) != 'undefined' ? p_ShowTime : false;

        p_Editable = typeof(p_Editable) != 'boolean' ? true : p_Editable;

        var calendarObj = new FullCalendar.Calendar($(p_Selector)[0], {
            plugins: [ 'interaction', 'dayGrid', 'timeGrid', 'list' ],
            height: 'parent',
            header: {
                left: 'today',
                center: 'prev,title,next',
                right: '' //'dayGridMonth,timeGridWeek,timeGridDay,listMonth'
            },
            defaultView: 'dayGridMonth',
            defaultDate: p_DefaultDate,
            snapDuration: 0,
            locale: 'ko',
            navLinks: false, // can click day/week names to navigate views (클릭시 해당 일자의 일정을 보여줌. Month 모드가 있어야 원래대로 돌아갈 수 있음)
            editable: p_Editable, // 편집 가능 여부 (클릭 이벤트는 발생하나, 기존 일정 드래그 & 드랍이 불가능 해짐)
            selectable: false, // 하나 또는 여러 개의 일자를 선택 가능할 수 있는지의 여부
            eventLimit: true, // 하루에 너무 많은 일정이 몰리면 more 라고 표시함
            themeSystem: "bootstrap",
            displayEventTime : p_ShowTime, // 일정에 시간 표시 여부
            eventSources: [{
                events: function(info, successCallback, failureCallback) {
                    let dataParam = {
                        "query_id" : p_QueryId,
                        "start" : moment(info.start).format("YYYYMMDD"),
                        "end" : moment(info.end).format("YYYYMMDD")
                    };
                    // 추가 파라미터 할당
                    for(let k in p_Params) {
                        dataParam[k] = p_Params[k];
                    }

                    $.ajax({
                        url: "/walletfree-admin/common_select.do",
                        type: "POST",
                        headers: { 'X-CSRF-TOKEN' : $('meta[name="csrf-token"]').attr('content') },
                        data: dataParam,
                        success: function(data, textStatus, jqXHR) {
                            successCallback(data);
                            p_CallbackFunction.call(null, data);
                        }
                    });
                }
            }],
            eventDrop: function(info) {
                // 일정을 드래그 & 드랍 한 후에 발동하는 이벤트 (info.revert() 하면 원래 일정으로 돌아감)
                p_UpdateFunction.call(null, info);
            },
            dateClick: function(info) {
                // 하나의 일자 클릭시
                // info.dateStr --> 2020-01-01
                p_ClickFunction.call(null, info);
            },
            eventResize: function(info) {
                // 크기 변경 후
                p_ResizeFunction.call(null, info);
            },
            eventClick: function(info) {
                // 일정 클릭 이벤트
                p_EventClickFunction.call(null, info);
            }
            // ,select: function(info) {
            //     // 여러 개의 일자를 드래그 & 드랍으로 선택시 (종료날짜-1일과 시작날짜가 같으면 수행하지 않도록 함)
            //     if(moment(info.start) != moment(info.end).add(-1, 'days')) {
            //         p_MultiSelectFunction.call(null, info);
            //     }
            // }
        });

        calendarObj.render();

        return calendarObj;
    };

    // DB 결과를 받아 특정 태그(보통 폼) 안의 input, select, textarea 에 세팅해 준다.
    // 단, 같은 이름으로 시작하는 ID가 있으면 안됨
    // 안되는 예) address, address2
    // 가능한 예) address1, address2
    $.fn.formSet = function(data) {
        var obj = $(this);
        var eachObj;
        if(data.length > 0) {
            // 받아온 데이터의 형식은 [{"key" : "value", ...}] 의 형식이므로 data[0] 값을 가지고 옴
            for(var itm in data[0]) {
                eachObj = $("#" + obj.attr("id")).find("[id='" + itm + "']");
                if(eachObj.length > 0) {
                    // id 일치 먼저 확인
                    if(typeof($(eachObj[0]).attr("data-daterangepicker")) != 'undefined') {
                        // DateRangePicker 사용시
                        $(eachObj[0]).data('daterangepicker').setStartDate(moment(data[0][itm]).format($(eachObj[0]).data('daterangepicker').locale.format));
                        $(eachObj[0]).data('daterangepicker').setEndDate(moment(data[0][itm]).format($(eachObj[0]).data('daterangepicker').locale.format));
                    } else if(typeof(eachObj.data("inputMasking")) != 'undefined') {
                        // 마스킹 사용시
                        eachObj.data("inputMasking").setValue(data[0][itm]);
                    } else if(eachObj[0].tagName.toLowerCase() == "input" && eachObj.attr("type").toLowerCase() == "radio") {
                        // 라디오의 경우 1개만 표시하면 id/name 이 일치함
                        $("#" + obj.attr("id")).find("[id='" + itm + "'][value='" + data[0][itm] + "']").prop("checked", true);
                    } else if(eachObj[0].tagName.toLowerCase() == "input" && eachObj.attr("type").toLowerCase() == "checkbox") {
                        // 체크박스의 경우 1개만 표시하면 id/name 이 일치함
                        var values = data[0][itm].split(",");
                        for(var i = 0; i < values.length; i++) {
                            if($("input[id='" + itm + "'][value='" + values[i] + "']").length > 0) {
                                $("input[id='" + itm + "'][value='" + values[i] + "']").prop("checked", true);
                            }
                        }
                    } else if(eachObj[0].tagName.toLowerCase() == "input" || eachObj[0].tagName.toLowerCase() == "select" || eachObj[0].tagName.toLowerCase() == "textarea") {
                        // 나머지 input과 select, textarea 처리
                        if(eachObj.hasClass("form-control") && !eachObj.hasClass("fill")) {
                            eachObj.addClass("fill");
                        }
                        eachObj.val(data[0][itm]);
                    }
                } else {
                    // 체크박스/라디오버튼은 여러 개 표시되는 경우 id와 name 속성이 다르기 때문에 name속성을 먼저 체크한다.
                    eachObj = $("#" + obj.attr("id")).find("[name='" + itm + "']");

                    if(eachObj.length > 0) {
                        if(eachObj[0].tagName.toLowerCase() == "input" && eachObj.attr("type").toLowerCase() == "radio") {
                            // eachObj 는 배열이므로 각각의 value값을 확인하여 찾음
                            $("#" + obj.attr("id")).find("[id^='" + itm + "'][value='" + data[0][itm] + "']").prop("checked", true);
                        } else if(eachObj[0].tagName.toLowerCase() == "input" && eachObj.attr("type").toLowerCase() == "checkbox") {
                            var values = data[0][itm].split(",");
                            for(var i = 0; i < values.length; i++) {
                                if($("input[id^='" + itm + "'][value='" + values[i] + "']").length > 0) {
                                    $("input[id^='" + itm + "'][value='" + values[i] + "']").prop("checked", true);
                                } else {
                                    $("input[id^='" + itm + "'][value='" + values[i] + "']").prop("checked", false);
                                }
                            }
                        }
                    }
                }
            }
        }
    };

    // 폼 안에 있는 내용들 전부 클리어
    $.fn.formClear = function() {
        var obj = $(this);
        $("#" + obj.attr("id") + " *").each(function(idx, elem) {
            if(typeof($(elem).attr("data-daterangepicker")) != 'undefined') {
                // daterangepicker 는 오늘 날짜로 변경함
                $(elem).data("daterangepicker").setStartDate(moment().format($(elem).data('daterangepicker').locale.format));
                $(elem).data("daterangepicker").setEndDate(moment().format($(elem).data('daterangepicker').locale.format));
            } else if($(elem)[0].tagName.toLowerCase() == "input" && ($(elem).attr("type").toLowerCase() == "radio" || $(elem).attr("type").toLowerCase() == "checkbox")) {
                // 체크박스이거나 라디오 버튼인 경우
                $("input[name='" + $(elem).attr("name") + "']").prop("checked", false);
            } else if($(elem)[0].tagName.toLowerCase() == "input" || $(elem)[0].tagName.toLowerCase() == "textarea") {
                // 이외의 경우
                if($(elem).hasClass("fill")) {
                    $(elem).removeClass("fill");
                }
                $(elem).val("");
            } else if($(elem)[0].tagName.toLowerCase() == "select") {
                $(elem).find("option:eq(0)").prop("selected", true);
            }
        });
    };

    $.fn.checkEmptyValue = function() {
        var obj = $(this);
        var chk_empty = false;
        var caption = "";
        var empty_obj = null;

        // var find_selector = "";
        var label_selector = "";

        // if($("#" + obj.attr("id") + " .form-danger").length > 0) {
        //     find_selector = "form-danger";
        //     label_selector = "float-label";
        // } else if($("#" + obj.attr("id") + " .has-danger").length > 0) {
        //     find_selector = "has-danger";
        //     label_selector = "control-label";
        // }

        // $("#" + obj.attr("id") + " ." + find_selector).each(function(idx, elem) {
        $("#" + obj.attr("id") + " .form-danger").add("#" + obj.attr("id") + " .has-danger").each(function(idx, elem) {

            label_selector = $("#" + obj.attr("id") + " .form-danger").length > 0 ? "float-label" : "control-label";

            if($(elem).find("select").length > 0) {
                $(elem).find("select").each(function(idx2, elem2) {
                    if($.trim($(elem2).val()) == "") {
                        chk_empty = true;
                        caption = $(elem).find("label." + label_selector).text();
                        empty_obj = $(elem2);
                    }
                });
            } else if($(elem).find("input[type='text']").length > 0) {
                $(elem).find("input[type='text']").each(function(idx2, elem2) {
                    if($.trim($(elem2).val()) == "") {
                        chk_empty = true;
                        caption = $(elem).find("label." + label_selector).text();
                        empty_obj = $(elem2);
                    }
                });
            } else if($(elem).find("input[type='checkbox']").length > 0) {
                if($(elem).find("input[type='checkbox']:checked").length < 1) {
                    chk_empty = true;
                    caption = $(elem).find("label." + label_selector).text();
                    empty_obj = $(elem).find("input[type='checkbox']").eq(0);
                }
            } else if($(elem).find("input[type='radio']").length > 0) {
                if($(elem).find("input[type='radio']:checked").length < 1) {
                    chk_empty = true;
                    caption = $(elem).find("label." + label_selector).text();
                    empty_obj = $(elem).find("input[type='radio']").eq(0);
                }
            } else if($(elem).find("textarea").length > 0) {
                $(elem).find("textarea").each(function(idx2, elem2) {
                    if($.trim($(elem2).val()) == "") {
                        chk_empty = true;
                        caption = $(elem).find("label." + label_selector).text();
                        empty_obj = $(elem2);
                    }
                });
            }

            if(chk_empty) {
                // continue;
                return false;
            }
        });

        if(chk_empty) {
            notifyDanger("항목을 입력해 주세요." + " (" + caption + ")");
            empty_obj.focus();
        }

        return chk_empty;
    };

    /**
     * 화면에 버튼을 넣어주는 함수. 권한에 따라 뿌려주도록 함
     * @param p_MenuId (String) 메뉴ID / 팝업ID
     * @param p_FormGubn (String) 폼 구분 (NORMAL, POPUP1, POPUP2, MODAL 중 하나)
     * @param p_FormCond (String) 구분값
     *
     * 사용법 예제
     *
     * $("#button_area").setButtonAuth("1", "POPUP", "A");
     *
     */
    $.fn.setButtonAuth = function(p_MenuId, p_FormGubn, p_FormCond) {

        var wrapObj = $(this);
        var sendParam = {
            "menu_id" : p_MenuId,
            "form_gubn" : p_FormGubn,
            "form_cond" : p_FormCond
        };

        wrapObj.html("");

        $.ajax({
            url: "/common_btn",
            data: sendParam,
            method: "POST",
            dataType: "json",
            success: function(result, textStatus, jqXHR) {

                var htmlStr = "";
                var attrStr = "";

                if(result.length > 0) {
                    for(var i = 0; i < result.length; i++) {
                        attrStr = "";

                        if(result[i]["btn_disp_type"] == "B") {
                            // data-val1, data-val2, data-val3 세팅
                            for(var j = 1; j < 4; j++) {
                                attrStr += result[i]["data_val" + j] == "" || result[i]["data_val" + j] == null ? "" : " data-val" + j + "=\"" + result[i]["data_val" + j] + "\" ";
                            }

                            htmlStr += '<button type="button" id="' + result[i]["btn_id"] + '" class="' + result[i]["btn_class"] + '" ' + attrStr + '>';
                            if(result[i]["icon_loc"] == "R") {
                                htmlStr += result[i]["btn_caption"] + '&nbsp;<i class="' + result[i]["btn_icon"] + '" style="margin-left:5px; margin-right:0px;"></i>';
                            } else {
                                htmlStr += '<i class="' + result[i]["btn_icon"] + '"></i>&nbsp;' + result[i]["btn_caption"];
                            }
                            htmlStr += '</button>&nbsp;';
                        } else if(result[i]["btn_disp_type"] == "R") {
                            // data-val1, data-val2, data-val3 세팅
                            for(var j = 1; j < 4; j++) {
                                attrStr += result[i]["data_val" + j] == "" ? "" : " data-val" + j + "=\"" + result[i]["data_val" + j] + "\" ";
                            }
                            htmlStr += '<i data-btn="btnGridButton" style="cursor:pointer;" title="' + result[i]["btn_caption"] + '" class="' + result[i]["btn_class"] + " " + result[i]["btn_icon"] + '" id="' + result[i]["btn_id"] + '" ' + attrStr + '></i>';
                        } else {
                            alert("항목을 입력해 주세요.");
                            break;
                        }
                    }

                    wrapObj.html(htmlStr);
                }
            },
            error: function(errorObj, textStatus, jqXHR) {
                if(typeof(console) != 'undefined') {
                    console.warn("setButtonAuth - btn_disp_type 값이 잘못되었습니다." + "\n(" + wrapObj["selector"] + ")");
                    console.warn(errorObj);
                }
            }
        })
    };

    // 일부 마스킹 씌우기
    // 종류 : number, phone, saupja, time, time2, date, date2, datetime
    $.fn.inputMasking = function(p_Type, p_Option) {

        var obj = $(this);

        if(typeof(p_Option) == 'undefined') {
            p_Option = {};
            p_Option["maxLength"] = 10;
            p_Option["decimal"] = 0;
        }

        p_Option["maxLength"] = typeof(p_Option["maxLength"]) != 'number' ? 10 : p_Option["maxLength"]; // 최대 길이
        p_Option["decimal"] = typeof(p_Option["decimal"]) != 'number' ? 0 : p_Option["decimal"];        // 숫자의 경우 소수점 길이
        p_Option["signed"] = typeof(p_Option["signed"]) != 'boolean' ? false : p_Option["signed"];      // 음수 사용 여부 (기본값: false)

        p_Option["min"] = typeof(p_Option["min"]) != 'number' ? null : p_Option["min"];
        p_Option["max"] = typeof(p_Option["max"]) != 'number' ? null : p_Option["max"];

        var min = p_Option["min"];                  // 최소값
        var max = p_Option["max"];                  // 최대값
        var maxLength = p_Option["maxLength"];      // 정수부 길이
        var decimal = p_Option["decimal"];          // 소수부 길이
        var signed = p_Option["signed"];            // 음수 사용여부
        var resultValue = "";                       // 결과값
        var undesiredStringRegExpression;                  // 필요하지 않은 문자열 제거를 위한 정규식
        var maskObject = null;                         // 마스킹 오브젝트 (전화번호는 오브젝트가 없음)
        var useNumberComma = false;

        switch(p_Type) {
            case "zip":
                $(this).attr("maxLength", 7);
                undesiredStringRegExpression = /[^0-9]/gi;
                maskObject = IMask.createMask({
                    mask: [{
                        mask: "00000"
                    }, {
                        mask: "000-000"
                    }]
                });
                break;
            case "number": // 일반 숫자 (콤마 없는 숫자와 처리 방식이 거의 같아서 같이 처리하도록 함)
                useNumberComma = true;
            case "number_nocomma": // 콤마 없는 숫자 (일반 숫자와 처리 방식이 거의 같아서 같이 처리하도록 함)
                undesiredStringRegExpression = /[^0-9.-]/gi;

                maskObject = IMask(obj[0], {
                    mask: Number,
                    min:    // min 값 설정한 경우에는 해당 값을 넣고, 아니면 maxLength 로 처리. 이도 없으면 0으로 처리.
                            (min != null) ? min : (signed ? -1 : 0) * (Math.pow(10, maxLength) - (parseFloat(1) / Math.pow(10, decimal))), // 최소값
                    max:    // max 값 설정한 경우에는 해당 값을 넣고, 아니면 maxLength 로 처리. 이도 없으면 10자리 숫자로 처리.
                            // 총 9자리 중 3자리가 소수점이면 정수부는 6자리.
                            // 위 예시의 경우, 최대값은 10의 6제곱 - 1 / (10의 6제곱) 이다.
                            (max != null) ? max : (Math.pow(10, maxLength) - (parseFloat(1) / Math.pow(10, decimal))), // 최대값
                    scale: decimal,                 // 소수점 자리수
                    thousandsSeparator: useNumberComma ? ',' : '',         // 천단위 콤마(다른 문자열 가능)
                    padFractionalZeros: false,      // 소수점이 없어도 자리수만큼 0 채우는 옵션 (false: 사용하지 않음)
                    normalizeZeros: true,           // appends or removes zeros at ends...?
                    radix: '.',                     // 소수점 문자열
                    mapToRadix: ['.'],              // 소수점을 입력할 키 ("." 키를 입력시 입력. "/" 이라고 하면 "/" 입력시 자동으로 소수점이 입력됨)
                    signed: signed
                });
                // $(this).attr("maxLength", maxLength + (decimal > 0 ? decimal + 1 : 0) + (signed ? 1 : 0));
                break;
            case "phone": // 전화번호
                $(this).attr("maxLength", 11);
                undesiredStringRegExpression = /[^0-9]/gi;
                break;
            case "saupja": // 사업자 등록번호
                $(this).attr("maxLength", 10);
                undesiredStringRegExpression = /[^0-9]/gi;
                maskObject = IMask.createMask({
                    mask: "000-00-00000"
                });
                break;
            case "time": // 시:분 형태의 문자열
                $(this).attr("maxLength", 4);
                undesiredStringRegExpression = /[^0-9]/gi;
                maskObject = IMask.createMask({
                    mask: "00:00"
                });
                break;
            case "time2": // 시:분:초 형태의 문자열
                $(this).attr("maxLength", 6);
                undesiredStringRegExpression = /[^0-9]/gi;
                maskObject = IMask.createMask({
                    mask: "00:00:00"
                });
                break;
            case "date": // 년-월-일 형태의 문자열
                $(this).attr("maxLength", 8);
                undesiredStringRegExpression = /[^0-9]/gi;
                maskObject = IMask.createMask({
                    mask: "0000-00-00"
                });
                break;
            case "date2": // 년-월 형태의 문자열
                $(this).attr("maxLength", 5);
                undesiredStringRegExpression = /[^0-9]/gi;
                maskObject = IMask.createMask({
                    mask: "0000-00"
                });
                break;
            case "datetime": // 년-월-일 시:분:초 형태의 문자열
                $(this).attr("maxLength", 14);
                undesiredStringRegExpression = /[^0-9]/gi;
                maskObject = IMask.createMask({
                    mask: "0000-00-00 00:00:00"
                });
                break;
        }

        obj.focus(function() {
            if($(this).prop("readonly") || $(this).prop("disabled")) {
                return;
            }
            if(p_Type == "number") {
                return;
            }
            $(this).val($(this).val().replace(undesiredStringRegExpression, ""));
        }).focusout(function() {
            if($(this).prop("readonly") || $(this).prop("disabled")) {
                return;
            }
            if(p_Type == "number") {
                return;
            }
            switch(p_Type) {
                case "zip":
                    resultValue = maskObject.resolve($(this).val());
                    break;
                case "number": // 일반 숫자
                case "number_nocomma":
                    // resultValue = maskObject.resolve($(this).val());
                    resultValue = $(this).val();
                    break;
                case "phone": // 전화번호 (common.js 에 해당 함수 존재함)
                    resultValue = returnPhoneNumber($(this).val());
                    break;
                case "saupja": // 사업자 등록번호
                    resultValue = maskObject.resolve($(this).val());
                    break;
                case "time": // 시:분 형태의 문자열
                    resultValue = maskObject.resolve($(this).val());
                    break;
                case "time2": // 시:분:초 형태의 문자열
                    resultValue = maskObject.resolve($(this).val());
                    break;
                case "date": // 년-월-일 형태의 문자열
                    resultValue = maskObject.resolve($(this).val());
                    break;
                case "date2": // 년-월 형태의 문자열
                    resultValue = maskObject.resolve($(this).val());
                    break;
                case "datetime": // 년-월-일 시:분:초 형태의 문자열
                    resultValue = maskObject.resolve($(this).val());
                    break;
            }

            $(this).val(resultValue);
        });

        var maskingFunctions = {
            type: p_Type,
            undesiredStringRegExp: undesiredStringRegExpression,
            maskObj: maskObject,
            setValue: function(p_RawValue) {
                p_RawValue = p_RawValue == null ? "" : p_RawValue;
                switch(this.type) {
                    case "number": // 일반 숫자
                        this.maskObj.unmaskedValue = p_RawValue;
                        break;
                    case "zip": // 우편번호 (5자리, 6자리)
                    case "saupja": // 사업자 등록번호
                    case "time": // 시:분 형태의 문자열
                    case "time2": // 시:분:초 형태의 문자열
                    case "date": // 년-월-일 형태의 문자열
                    case "date2": // 년-월 형태의 문자열
                    case "datetime": // 년-월-일 시:분:초 형태의 문자열
                        obj.val(this.maskObj.resolve(p_RawValue.replace(this.undesiredStringRegExp, "")));
                        break;
                    case "phone": // 전화번호
                        obj.val(returnPhoneNumber(p_RawValue.replace(this.undesiredStringRegExp, "")));
                        break;
                }
            },
            getValue: function() {
                return obj.val().replace(this.undesiredStringRegExp, "");
            },
            getMaskedValue: function() {
                return obj.val();
            }
        };

        obj.data("inputMasking", $.extend(true, {}, maskingFunctions));

        return this;
    };

    /**
     * readonly 속성을 변경함.
     * initDateOnly, initTimeOnly, initDateTime 함수 사용한 객체인 경우 readonly=true 일때에는 달력 제거, false 일때에는 달력 설정을 해 준다.
     *
     * @param p_Readonly true: 수정불가, false: 수정가능
     * @param p_Option 추가 옵션
     */
    // 옵션
    // {
    //      "keep_icon" : true,             // readonly 속성 변경시 아이콘을 숨기거나(false) 숨기지 않게(true) 처리함
    //      "reaonly_icon" : "fas fa-eye"   // readonly=true 로 변경할 경우 바꿀 아이콘의 클래스 이름
    // }
    $.fn.changeReadonly = function(p_Readonly, p_Option) {

        p_Option = p_Option || {};

        // readonly 되어도 아이콘을 유지할 지의 여부 (기본 false)
        p_Option["keep_icon"] = typeof(p_Option["keep_icon"]) != 'boolean' ? true : p_Option["keep_icon"];
        p_Option["readonly_icon"] = typeof(p_Option["readonly_icon"]) == 'undefined' ? "" : p_Option["readonly_icon"];

        var elem = $(this);
        var dateType = "";
        var oldValue = "";
        var isDatePicker;
        var obj;

        for(var i = 0; i < elem.length; i++) {
            obj = $(elem[i]);
            isDatePicker = typeof(obj.attr("data-daterangepicker")) != 'undefined';

            if(isDatePicker) {
                // 날짜의 경우 readonly 속성을 바꾸지는 않음
                // 강제로 true 로 세팅해 줌
                obj.prop("readonly", true);

                dateType = obj.attr("data-daterangepicker");

                if(p_Readonly) {
                    // daterangepicker 제거 (api 에도 제거 방법이 없어서 이벤트를 모두 제거하도록 처리함)
                    obj.unbind();
                } else {
                    // daterangepicker 추가

                    // 기존 값 보존
                    oldValue = obj.val();

                    // 초기화
                    if(dateType == "date-only") {
                        obj.initDateOnly("days", 0);
                    } else if(dateType == "date-time") {
                        obj.initDateTime("days", 0);
                    } else if(dateType == "time-only") {
                        obj.initTimeOnly("days", 0);
                    } else if(dateType == "date-single") {
                        obj.initDateSingle(obj.attr("data-daterangepicker-type"), oldValue);
                    }

                    // 기존값 세팅
                    obj.changeDateRange(oldValue);
                }
            } else {
                // readonly 속성 변경
                obj.prop("readonly", p_Readonly);
            }

            if(obj.parent().find(".float-label").length > 0) {
                // 상단 검색조건 디자인인 경우
                obj.prop("readonly", p_Readonly);
            } else {
                // 폼 입력 디자인인 경우 (신규 디자인)
                if(obj.parent().find(".input-group-addon").length > 0) {

                    if(p_Option["keep_icon"] == false) {
                        obj.parent().find(".input-group-addon").css("display", (p_Readonly ? "none" : ""));
                    } else {
                        if(p_Readonly) {
                            if(p_Option["readonly_icon"] != "") {
                                obj.parent().find(".input-group-addon").children("i")[0].className = p_Option["readonly_icon"];
                            }
                        } else {
                            obj.parent().find(".input-group-addon").children("i")[0].className = obj.parent().find(".input-group-addon").children("i").attr("data-icon");
                        }
                    }
                }
            }
        }

        return this;
    };

    /**
     * disabled 속성을 변경함
     *
     * @param p_Disabled true: 수정불가, false: 수정가능
     * @param p_Option 추가 옵션
     */
    // 옵션
    // {
    //      "keep_icon" : true,             // disabled 속성 변경시 아이콘을 숨기거나(false) 숨기지 않게(true) 처리함
    //      "disabled_icon" : "fas fa-eye"   // disabled=true 로 변경할 경우 바꿀 아이콘의 클래스 이름
    // }
    $.fn.changeDisabled = function(p_Disabled, p_Option) {

        p_Option = p_Option || {};

        // readonly 되어도 아이콘을 유지할 지의 여부 (기본 false)
        p_Option["keep_icon"] = typeof(p_Option["keep_icon"]) != 'boolean' ? true : p_Option["keep_icon"];
        p_Option["disabled_icon"] = typeof(p_Option["disabled_icon"]) == 'undefined' ? "" : p_Option["disabled_icon"];

        var elem = $(this);
        var obj;

        for(var i = 0; i < elem.length; i++) {
            obj = $(elem[i]);

            if(obj.parent().find(".float-label").length > 0) {
                // 상단 검색조건 디자인인 경우
                obj.prop("disabled", p_Disabled);
            } else {
                // 폼 입력 디자인인 경우 (신규 디자인)
                obj.prop("disabled", p_Disabled);

                if(obj.parent().find(".input-group-addon").length > 0) {
                    if(p_Option["keep_icon"] == false) {
                        obj.parent().find(".input-group-addon").css("display", (p_Disabled ? "none" : ""));
                    } else {
                        if(p_Disabled) {
                            if(p_Option["disabled_icon"] != "") {
                                obj.parent().find(".input-group-addon").children("i")[0].className = p_Option["disabled_icon"];
                            }
                        } else {
                            obj.parent().find(".input-group-addon").children("i")[0].className = obj.parent().find(".input-group-addon").children("i").attr("data-icon");
                        }
                    }
                }
            }
        }

        return this;
    };

    // 라벨 변경
    $.fn.changeLabel = function(p_Caption) {
        var elem = $(this);
        var obj;

        for(var i = 0; i < elem.length; i++) {
            obj = $(elem[i]);
            if(obj.parent().find(".float-label").length > 0) {
                // 상단 검색조건 디자인인 경우
                obj.parent().find(".float-label").text(p_Caption);
            } else {
                // 폼 입력 디자인인 경우 (신규 디자인)
                obj.parent().parent().parent().find(".control-label").text(p_Caption);
            }
        }

        return this;
    };

    // 색깔 변경
    // 상단 검색조건 디자인인 경우 success, danger, warning 만 사용 가능
    // 폼 입력 디자인(신규)인 경우 success, danger, info 만 사용 가능
    $.fn.changeColor = function(p_Color) {
        var elem = $(this);
        var obj;
        for(var i = 0; i < elem.length; i++) {
            obj = $(elem[i]);
            if(obj.parent().find(".float-label").length > 0) {
                // 상단 검색조건 디자인인 경우
                // info, danger, success
                // 폼 입력 디자인인 경우 (신규 디자인)
                obj.parent().removeClass("form-success");
                obj.parent().removeClass("form-info");
                obj.parent().removeClass("form-danger");
                obj.parent().removeClass("form-static-label");
                if(p_Color != "") {
                    obj.parent().addClass("form-" + p_Color).addClass("form-static-label");
                }
            } else {
                // 폼 입력 디자인인 경우 (신규 디자인)
                obj.parent().parent().parent().removeClass("has-success");
                obj.parent().parent().parent().removeClass("has-warning");
                obj.parent().parent().parent().removeClass("has-danger");
                if(p_Color != "") {
                    obj.parent().parent().parent().addClass("has-" + p_Color);
                }
            }
        }

        return this;
    };

    // 아이콘 변경 (신규 디자인인 경우에만 가능함)
    $.fn.changeIcon = function(p_Icon) {
        var elem = $(this);
        var obj;
        for(var i = 0; i < elem.length; i++) {
            obj = $(elem[i]);
            if(obj.parent().find("[data-icon]").length > 0) {
                obj.parent().find("[data-icon]")[0].className = "";
                obj.parent().find("[data-icon]").addClass(p_Icon);
            }
        }

        return this;
    };
})(jQuery);
