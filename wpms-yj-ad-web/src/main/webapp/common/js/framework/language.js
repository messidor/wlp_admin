var PageLang = {
    defaultLang: "ko_kr",
    "ko_kr": {
        searchOKMsg: "조회가 완료되었습니다.",
        handleOKMsg: "정상적으로 처리되었습니다.",
        handleNOMsg: "처리 도중 오류가 발생하였습니다.",
        handleErrorMsg: "서버 오류가 발생하였습니다.",
        noReqValue: "필수값을 입력하지 않으셨습니다.",
        thisIsReqField: ": 필수 항목",
        "gridHelper": {
            "setColumn": {
                RequiredError: "setColumn: 첫번째 파라미터가 잘못되었습니다(최소 fieldName, headerName 필요).",
                EditError: "setColumn: 두번째 파라미터가 잘못되었습니다(최소 editable 필요)."
            },
            "initGrid": {
                EditingNowError: "그리드 편집 도중에는 사용할 수 없습니다."
            }
        },
        "write_detail": {
            AutoSaveOK: "자동 저장이 완료되었습니다."
        }
    },
    "en_us": {
        searchOKMsg: "Data search was completed.",
        handleOKMsg: "Processing was successful.",
        handleNOMsg: "An error occured during processing.",
        handleErrorMsg: "A server error has occured.",
        noReqValue: "There is no value for required field.",
        thisIsReqField: ": Required Field",
        "gridHelper": {
            "setColumn": {
                RequiredError: "setColumn: Invalid first parameter(required: fieldName, headerName).",
                EditError: "setColumn: Invalid second parameter(required: editable)."
            },
            "initGrid": {
                EditingNowError: "You cannot use this function while you are editing in grid."
            }
        },
        "write_detail": {
            AutoSaveOK: "Auto-Save was completed."
        }
    },
    msg: function(p_LangKey) {
        var lang_key = "";
        var result_msg = "";
        if(p_LangKey.indexOf(".") > -1) {
            var lang_split = p_LangKey.split(".");
            for(var str in lang_split) {
                lang_key += "[\"" + lang_split[str] + "\"]";
            }
        } else {
            lang_key = "[\"" + p_LangKey + "\"]";
        }

        eval("result_msg = this[this.defaultLang]" + lang_key + ";");

        return result_msg;
    }
};
