// 아무 역할도 없는 함수 생성
var noop = noop || function() {};

//"U" + 금일 날짜(Microsecond까지, 17자리) + 랜덤숫자 14자리 생성
function getUuidV4() {
    let today = new Date();
    let uuid = today.getFullYear() + ("0" + (today.getMonth() + 1)).slice(-2) + ("0" + today.getDate()).slice(-2)
                + ('0' + today.getHours()).slice(-2) + ('0' + today.getMinutes()).slice(-2) + ('0' + today.getSeconds()).slice(-2) + ("" + today.getMilliseconds());
    
    for(let i = 0; i < 14; i++) {
        uuid += (Math.floor(Math.random() * 10) + "");
    }
    
    return "U" + uuid;
}

/**
 * 파일키, 릴레이션키를 통해 해당 파일을 다운받을 수 있는 URL을 받아옴, 로그인 필요 (Ajax 필수)
 * @param encData 릴레이션키 + "|" + 파일키 암호화 한 문자열
 * @param openType "P" : 새 탭에서 열기, "W" : 현재창에서 열기, 다른값을 주면 다운로드를 자동실행하지 않음(location.href 또는 window.open 직접 사용 필요)
 * @param successFunction 성공시 수행하는 함수(함수 실행 후 다운로드 진행)
 * @param errorFunction 실패시 수행하는 함수(기본값은 화면에 오류 메시지를 action_popup.alert로 표시)
 * @returns 없음
 */
function startDownload(encData, openType, successFunction, errorFunction) {
    
    $.ajax({
        type : 'POST',
        url : "/walletfree-admin/down/makeUrl.do",
        data : {"data" : encData},
        dataType : 'json',
        async : true,
        cache : false,
        contentType : 'application/x-www-form-urlencoded; charset=UTF-8',
        processData : true,
        success : function (response, textStatus) {
            if(parseInt(response.count, 10) > 0) {
                if(typeof(successFunction) == "function") {
                    successFunction.call(null, response, response.data.url);
                }
                if("P" == openType.toUpperCase()) {
                    window.open(response.data.url); // 새창
                } else if("W" == openType.toUpperCase()) {
                    location.href = response.data.url; // 현재창
                }
            } else {
                if(typeof(errorFunction) == "function") {
                    errorFunction.call(null, response);
                } else {
                    if(typeof(action_popup) != 'undefined') {
                        action_popup.alert((response.message ? response.message : response.msg));
                    } else {
                        alert((response.message ? response.message : response.msg));
                    }
                }
            }
        },
        error : function (jqXHR, textStatus, errorThrown) {
            if(action_popup) {
                action_popup.alert("다운로드중 오류가 발생하였습니다.");
            } else {
                alert("다운로드중 오류가 발생하였습니다.");
            }
        }
    });
}

if(typeof($) != undefined) {
    $(function() {
        /**
         * jQuery.sumoselect 플러그인을 사용하여 Multi select (체크박스 있음)를 구현
         * @param defaultValues 기본으로 선택해야 할 값
         * @param options jQuery.sumoselect 플러그인에서 지원하는 옵션
         * @param events jQuery.sumoselect 플러그인에서 지원하는 이벤트(change 이벤트도 포함함)
         * @returns
         */
        $.fn.setMultiSelect = function(defaultValues, options, events) {
            let obj = $(this);
            // jQuery.sumoselect 플러그인을 사용하여 Multi select (체크박스 있음)를 구현
            // https://hemantnegi.github.io/jquery.sumoselect/ (파라미터 참조)
            // MIT 라이선스
            
            // multiple 속성 추가
            obj.attr("multiple", "multiple");
            
            // 선택되어야 하는 값
            defaultValues = defaultValues || [];
            
            // 기본 옵션
            use_options = {
                    placeholder              : options["placeholder"]               || '선택',            // 아무것도 선택 안할시 나타나는 문구
                    csvDispCount             : options["csvDispCount"]              || 1,                 // 박스에 보이는 최대 항목 개수
                    captionFormat            : options["captionFormat"]             || '{0}개 선택됨',    // 선택시 문구
                    captionFormatAllSelected : options["captionFormatAllSelected"]  || '전체 선택됨',     // 전체 선택시 문구
                    floatWidth               : options["floatWidth"]                || 500,               // 기기의 최소 너비?
                    forceCustomRendering     : options["forceCustomRendering"]      || false,            // 안드로이드처럼 선택 박스를 모달 팝업 형태로 강제로 처리할지의 여부
                    nativeOnDevice           : options["nativeOnDevice"]            || ['Android', 'BlackBerry', 'iPhone', 'iPad', 'iPod', 'Opera Mini', 'IEMobile', 'Silk'],   // navigator.userAgent 에서 확인 가능한 기기 목록 (해당 기기에서 제공하는 기본 UI를 사용하게 하기 위함)
                    outputAsCSV              : options["outputAsCSV"]               || true,             // obj[0].sumo.getSelStr() 사용시 특정 문자열로 구분하여 하나로 합칠지의 여부
                    csvSepChar               : options["csvSepChar"]                || ',',               // obj[0].sumo.getSelStr() 사용시 구분할 문자열
                    okCancelInMulti          : options["okCancelInMulti"]           || false,            // 다수 선택시 선택/취소 버튼 사용 여부
                    isClickAwayOk            : options["isClickAwayOk"]             || false,            // okCancelInMulti=true 일 때 바깥을 클릭했을 시 OK로 간주할 지의 여부
                    triggerChangeCombined    : options["triggerChangeCombined"]     || true,             // 다중 선택시 개별 선택이 변경될 때 change 이벤트를 발생할 지의 여부
                    selectAll                : options["selectAll"]                 || true,             // 전체 선택 사용 여부
                    selectAllPartialCheck    : options["selectAllPartialCheck"]     || true,             // 전체 선택 사용시 "전체 선택" 체크박스를 전체 선택이 안되어 있을 때 회색으로 표시할지의 여부
                    search                   : options["search"]                    || false,            // 검색 기능 사용 여부
                    searchText               : options["searchText"]                || '검색',            // 검색 기능 사용시 검색 창에 넣을 placeholder
                    searchFn                 : options["searchFn"]                  || function(haystack, needle, el) { }, // 검색 함수
                    noMatch                  : options["noMatch"]                   || '결과 없음',       // 결과 없을 때의 문구
                    prefix                   : options["prefix"]                    || '',                // 선택한 텍스트의 앞에 붙여줄 HTML
                    locale                   : options["locale"]                    || ['확인', '취소', '전체선택'],   // 확인, 취소, 전체선택 문구
                    up                       : options["up"]                        || false,            // 위로 표시할지의 여부
                    showTitle                : options["showTitle"]                 || true,             // 마우스 오버할 때 title 속성 표시 여부 
                    max                      : options["max"]                       || null,             // 최대 선택 가능 개수
                    renderLi                 : options["renderLi"]                  || (function(li, originalOption) { return li; }),   // 커스텀 목록 renderer
                    clearAll                 : options["clearAll"]                  || false,           // 모두 지움 활성화 여부
                    closeAfterClearAll       : options["closeAfterClearAll"]        || false,           // 모두 지움 선택시 창을 닫을지의 여부
                    
                    //////////////////////////// 여기서부터는 직접 추가한 옵션
                    min                      : options["min"] || 0,                                      // 최소로 선택해야 하는 개수
            };
            
            // 기본 이벤트
            let event_functions = {
                    "sumo:initialized"       : (events["initialized"] || noop),     // 초기화 후 발생
                    "sumo:opening"           : (events["opening"] || noop),         // 박스를 열 때 발생
                    "sumo:opened"            : (events["opened"] || noop),          // 박스를 열고 나서 발생
                    "sumo:closing"           : (events["closing"] || noop),         // 박스가 닫힐 때 발생
                    "sumo:closed"            : (events["closed"] || noop),          // 박스가 닫힌 후 발생
                    "sumo:unloaded"          : (events["unloaded"] || noop),        // sumoselect 를 없애고 난 후에 발생
                    /////////////////////////// 직접 추가한 이벤트
                    "auto:change"            : (events["change"] || noop),          // 변경시 이벤트
                    "minLimitExceed"         : (events["minLimit"] || function() {         // 선택해야 할 최소 개수를 충족하지 못하면 발생
                        setTimeout(function() {
                            obj[0].sumo.showOpts();
                            alert("최소 " + use_options["min"] + "개 이상 선택하셔야 합니다.");
                        }, 100);
                    }),
            };
            
            // 기존 변경 이벤트 삭제
            obj.off("change");
            
            // multiselect 플러그인 추가
            obj.SumoSelect(use_options);
            
            // CSS 처리..
            if(obj.parentsUntil(".card-block").parent()[0] !== document) {
                $(obj.parentsUntil(".card-block").parent()[0]).css("overflow", "visible");
            }
            
            // 전체 선택 해제 (기존에 기본 1개가 자동으로 선택되어 있어서 모두 해제 처리)
            obj[0].sumo.unSelectAll();
            
            // 기본값 선택
            if(defaultValues.length > 0) {
                for(let i = 0; i < defaultValues.length; i++) {
                    obj[0].sumo.selectItem(defaultValues[i]);
                }
            }
            
            // 이벤트 처리
            for(let key in event_functions) {
                if(key.startsWith("sumo:") || key.startsWith("auto:")) {
                    if(key == "sumo:closed") {
                        // 닫힐 때 체크하도록 하기 위해 추가하였음
                        obj.on(key, function(e, sumo) {
                            let isSelectedCountOk = true;
                            
                            if(use_options["min"] != null) {
                                if(use_options["min"] > 0) {
                                    if(sumo.getSelStr().length > 0) {
                                        if(sumo.getSelStr().split(",").length < use_options["min"]) {
                                            isSelectedCountOk = false;
                                        }
                                    } else {
                                        isSelectedCountOk = false;
                                    }
                                }
                            }
                            
                            if(!isSelectedCountOk) {
                                event_functions["minLimitExceed"].call(null, e, sumo)
                            } else {
                                event_functions[key].call(null, e, sumo);
                            }
                        });
                    } else {
                        obj.on(key, event_functions[key]);
                    }
                }
            }
            
            // 값을 콤마와 작은따옴표를 붙여서 가져오는 함수를 붙여주도록 함(IN절에 사용하기 위함)
            obj[0].sumo.getListTypeValue = function() {
                let self = this;
                let valueStr = self.getSelStr();
                let retStr = "";
                
                if(valueStr.length > 0) {
                    let valueList = valueStr.split(",");
                    for(let i = 0; i < valueList.length; i++) {
                        retStr += (i > 0 ? ", " : "") + "'" + valueList[i] + "'";
                    }
                    return retStr;
                } else {
                    // 값이 없으면 DB의 빈값을 의미하는 작은따옴표 두개('')를 넣음
                    return "''";
                }
            };
            
            return obj;
        };
    });
}