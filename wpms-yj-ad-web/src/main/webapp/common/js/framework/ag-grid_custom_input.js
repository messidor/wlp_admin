var GridCustomRenderer = {
    userInputBoxRenderer: function() {
        //
    }
}



var GridCustomEditor = {
    userInputBoxEditor: function() {
        var objParent = $(this);

        function InputBoxEditor() {}

        InputBoxEditor.prototype.init = function(params) {
            var obj = this;
            obj.eInput = document.createElement("input");
            obj.eInput.type = "text";
            obj.eInput.value = params.value;
            obj.eInput.className = "ag-cell-edit-input";

            // 필수값 지정된 경우에 연한 색깔로 처리 가능하게 함 (style.css)
            if(typeof(params.colDef.required) != 'undefined') {
                if(params.colDef.required == true) {
                    obj.eInput.className = obj.eInput.className + " grid-required-cell";
                }
            }

            if(params.colDef.maskType == "" || params.colDef.maskType == "string") {
                // 일반 스트링
                obj.eInput.type = "text";
            } else if(params.colDef.maskType.indexOf("number") > -1) {
                // number 인 경우
                obj.eInput.type = "text";
                obj.eInput.className = obj.eInput.className + " jQueryNumericInputCheck";

                // 점(".") 개수
                var dot_count = (params.colDef.maskType.match(/\./g) || []).length;

                if(dot_count <= 0) {
                    // 기본 number
                } else if(dot_count == 1) {
                    // 점 1개인 경우 (정수 자릿수)
                } else if(dot_count == 2) {
                    // 점 2개인 경우 (정수, 소수 자릿수)
                } else {
                    console.warn("colDef.maskType error: Invalid using \"number\".");
                }
            } else {
                obj.eInput.type = params.colDef.maskType;
            }

            // maxLength 지정된 경우 지정시킴
            if(typeof(params.colDef.maxLength) != 'undefined' && params.colDef.maskType.indexOf("number") <= -1) {
                var max_length = parseInt(params.colDef.maxLength, 10);
                max_length = isNaN(max_length) ? 0 : max_length;

                if(max_length > 0) {
                    this.eInput.maxLength = max_length;
                }
            }
        }
        InputBoxEditor.prototype.getGui = function(params) {
            return this.eInput;
        }
        InputBoxEditor.prototype.afterGuiAttached = function(params) {
            this.eInput.focus();
        }
        InputBoxEditor.prototype.getValue = function(params) {
            return this.eInput.value;
        }
        InputBoxEditor.prototype.destroy = function(params) {}
        InputBoxEditor.prototype.isPopup = function(params) {
            return false;
        }

        return InputBoxEditor;
    },
    userCheckBoxEditor: function() {
        // 체크박스처럼 그래픽 처리를 하여 보여주기 위한 에디터
        var objParent = $(this);
        this.columnName = "";
        function CheckPicker() {}

        CheckPicker.prototype.init = function(params) {
            // create the cell
            this.eInput = document.createElement('label');
            this.eInput.style = "width:100%; text-align:center;";
            this.eInput.innerHTML = '<input type="checkbox" class="ag-cell-edit-input" ' + (params.value != "Y" ? " checked=\"checked\"" : "") + "/>";

            this.columnName = params.colDef.field;
        };

        // gets called once when grid ready to insert the element
        CheckPicker.prototype.getGui = function() {
            return this.eInput;
        };

        // focus and select can be done after the gui is attached
        CheckPicker.prototype.afterGuiAttached = function() {
            // console.log("CheckPicker afterGuiAttached...");
        };

        // 편집후 적용시 값 리턴
        CheckPicker.prototype.getValue = function() {
            var obj = $(this.eInput).children("input");
            return obj.is(":checked") ? "Y" : "N";
        };

        // any cleanup we need to be done here
        CheckPicker.prototype.destroy = function() {
        };

        // if true, then this editor will appear in a popup
        CheckPicker.prototype.isPopup = function() {
            return false;
        };

        return CheckPicker;
    },
    userCheckBoxEditorAlpine: function() {
        // 기존 ag-grid 의 Alpine 테마의 체크박스를 이용한 체크/체크 해제
        var objParent = $(this);
        this.columnName = "";
        function CheckPickerAlpine() {}

        CheckPickerAlpine.prototype.init = function(params) {
            // create the cell
            this.eInput = document.createElement('label');
            this.eInput.className = "ag-theme-alpine-custom ag-checkbox-custom-wrapper";
            this.eInput.innerHTML = '<input type="checkbox" class="ag-cell-edit-input ag-checkbox-custom" ' + (params.value != "Y" ? " checked=\"checked\"" : "") + "/>";

            this.columnName = params.colDef.field;
        };

        // gets called once when grid ready to insert the element
        CheckPickerAlpine.prototype.getGui = function() {
            return this.eInput;
        };

        // focus and select can be done after the gui is attached
        CheckPickerAlpine.prototype.afterGuiAttached = function() {
            // console.log("CheckPicker afterGuiAttached...");
        };

        // 편집후 적용시 값 리턴
        CheckPickerAlpine.prototype.getValue = function() {
            var obj = $(this.eInput).find("input");
            return obj.is(":checked") ? "Y" : "N";
        };

        // any cleanup we need to be done here
        CheckPickerAlpine.prototype.destroy = function() {
        };

        // if true, then this editor will appear in a popup
        CheckPickerAlpine.prototype.isPopup = function() {
            return false;
        };

        return CheckPickerAlpine;
    },
    userRadioEditor: function() {
        // 체크박스처럼 그래픽 처리를 하여 보여주기 위한 에디터
        var objParent = $(this);
        this.columnName = "";
        function RadioPicker() {}

        RadioPicker.prototype.init = function(params) {
            // create the cell
            // this.eInput = document.createElement('label');
            // this.eInput.style = "width:100%; text-align:center;";
            // this.eInput.innerHTML = '<input type="radio" name="' + params.api.gridCore.eGridDiv.id + '_' + params.colDef.field + '" class="ag-cell-edit-input" ' + (params.value != "Y" ? " checked=\"checked\"" : "") + "/>";

            // 여기서 colDef  참조하여 json 배열을 가지고 와서 세팅 후 뿌려줌
            var retHtml = "";
            var rdoTextName = "";
            var rdoValueName = "";
            for(var data in params.colDef.cellEditorParams.datas) {
                rdoTextName = params.colDef.cellEditorParams.textName;
                rdoValueName = params.colDef.cellEditorParams.valueName;
                retHtml += '<label class="custom-ag-grid-radio-label"><input type="radio" name="' + params.api.gridCore.eGridDiv.id + '_' + params.colDef.field + '" class="ag-cell-edit-input" value="' + params.colDef.cellEditorParams.datas[data][rdoValueName] + '" style="height:auto; width:auto;" ' + (params.value != params.colDef.cellEditorParams.datas[data][rdoValueName] ? " checked=\"checked\"" : "") + '/>&nbsp;' + params.colDef.cellEditorParams.datas[data][rdoTextName] + '</label>';
            }

            this.eInput = document.createElement('label');
            this.eInput.style = "width:100%; text-align:center;";
            this.eInput.innerHTML = retHtml;

            this.columnName = params.colDef.field;
        };

        // gets called once when grid ready to insert the element
        RadioPicker.prototype.getGui = function() {
            return this.eInput;
        };

        // focus and select can be done after the gui is attached
        RadioPicker.prototype.afterGuiAttached = function() {
            // console.log("RadioPicker afterGuiAttached...");
        };

        // 편집후 적용시 값 리턴
        RadioPicker.prototype.getValue = function() {
            var radios = $(this.eInput).children("input");

            for(var rdo in radios) {
                if(radios[rdo].is(":checked")) {
                    return radios[rdo].val();
                }
            }

            return "";
        };

        // any cleanup we need to be done here
        RadioPicker.prototype.destroy = function() {
        };

        // if true, then this editor will appear in a popup
        RadioPicker.prototype.isPopup = function() {
            return false;
        };

        return RadioPicker;
    },
    userRowRadioEditor: function() {
        // 체크박스처럼 그래픽 처리를 하여 보여주기 위한 에디터
        var objParent = $(this);
        this.columnName = "";
        function RowRadioEditor() {}

        RowRadioEditor.prototype.init = function(params) {
            // create the cell
            this.eInput = document.createElement('label');
            this.eInput.style = "width:100%; text-align:center;";
            this.eInput.innerHTML = '<input type="radio" name="' + params.api.gridCore.eGridDiv.id + '_' + params.colDef.field + '" class="ag-cell-edit-input" ' + (params.value != "Y" ? " checked=\"checked\"" : "") + "/>";

            this.columnName = params.colDef.field;
        };

        // gets called once when grid ready to insert the element
        RowRadioEditor.prototype.getGui = function() {
            return this.eInput;
        };

        // focus and select can be done after the gui is attached
        RowRadioEditor.prototype.afterGuiAttached = function() {
            // console.log("RowRadioPicker afterGuiAttached...");
        };

        // 편집후 적용시 값 리턴
        RowRadioEditor.prototype.getValue = function() {
            var obj = $(this.eInput).children("input");
            return obj.is(":checked") ? "Y" : "N";
        };

        // any cleanup we need to be done here
        RowRadioEditor.prototype.destroy = function() {
        };

        // if true, then this editor will appear in a popup
        RowRadioEditor.prototype.isPopup = function() {
            return false;
        };

        return RowRadioEditor;
    },
    userDateOnlyPickerEditor: function() {
        // datepicker, timepicker 를 그리드에 그리기 위함
        var objParent = $(this);
        function Datepicker() {}

        Datepicker.prototype.init = function(params) {
            // create the cell

            this.eGui = document.createElement('div');
            this.eGui.id = "datepicker_grid";
            this.eGui.className = "input-group";

            var drObj = $(this.eGui);

            var useTimePicker = false;
            var formatString = "";
            var minViewMode = "days";
            var momentFormat = "";

            useTimePicker = false;
            formatString = "yyyy-mm-dd";

            // date_format 속성을 받아서 년월일/년월/년도 중 하나를 결정하도록 함
            // grid에서 사용하는 moment, display의 format을 동일하게 수정
            // min0
            switch(params.colDef.inputType.toLowerCase()) {
                case "date":
                    momentFormat = "YYYY-MM-DD";
                    formatString = "yyyy-mm-dd";
                    minViewMode = "days";
                    break;
                case "month":
                    momentFormat = "YYYY-MM";
                    formatString = "yyyy-mm";
                    minViewMode = "months";
                    break;
                case "year":
                    momentFormat = "YYYY";
                    formatString = "yyyy";
                    minViewMode = "years";
                    break;
            }

            drObj.datepicker({
                "container" : "#datepicker_grid",
                "autoclose" : true,
                "format" : formatString,
                "language" : "ko",
                "minViewMode" : minViewMode
            }).datepicker('setDate', new Date(StringToDate(params.value, "-"))).on("changeDate", function() {
                params.api.stopEditing();
            });

            // datepicker 종류 저장
            drObj.attr("data-datepicker-type", params.colDef.cellEditor);
            // 포맷 저장 (moment용)
            drObj.attr("data-datepicker-format", momentFormat);
            // 포맷 저장 (display용)
            drObj.attr("data-datepicker-display-format", formatString);
            // 값 저장
            drObj.attr("data-datepicker-value", params.value);
            // timepicker 사용 여부 저장 (T/F 로 저장)
            drObj.attr("data-datepicker-useTimePicker", useTimePicker ? "T" : "F");
        };

        // gets called once when grid ready to insert the element
        Datepicker.prototype.getGui = function() {
            return this.eGui;
        };

        // focus and select can be done after the gui is attached
        Datepicker.prototype.afterGuiAttached = function() {
            $(this.eGui).datepicker('show');
        };

        // returns the new value after editing
        Datepicker.prototype.getValue = function() {
            return $(this.eGui).datepicker("getDate") ? moment($(this.eGui).datepicker("getDate")).format($(this.eGui).attr("data-datepicker-format")) : "";
        };

        // any cleanup we need to be done here
        Datepicker.prototype.destroy = function() {

        };

        // if true, then this editor will appear in a popup
        Datepicker.prototype.isPopup = function() {
            // and we could leave this method out also, false is the default
            return true;
        };

        return Datepicker;
    },
    userMaskingEditor: function() {

        var objParent = $(this);

        function MaskingEditor() {}

        MaskingEditor.prototype.init = function(params) {
            var obj = this;
            obj.eInput = document.createElement("input");
            obj.eInput.type = "text";
            obj.eInput.value = params.value;
            obj.eInput.className = "ag-cell-edit-input";

            $(obj.eInput).on("focus", function() {
            	$(this).select();
            });
            
            // 필수값 지정된 경우에 연한 색깔로 처리 가능하게 함 (style.css)
            if(typeof(params.colDef.required) != 'undefined') {
                if(params.colDef.required == true) {
                    obj.eInput.className = obj.eInput.className + " grid-required-cell";
                }
            }

            // 마스킹 인스턴스
            obj.eInput.maskObj = IMask(obj.eInput, {
                mask: params.colDef["cellEditorParams"]["maskType"],
                min:    // min 값 설정한 경우에는 해당 값을 넣고, 아니면 maxLength 로 처리. 이도 없으면 0으로 처리.
                        (params.colDef["cellEditorParams"]["min"] != null)
                      ? params.colDef["cellEditorParams"]["min"]
                      : ((params.colDef["cellEditorParams"]["signed"] ? -1 : 0) * (Math.pow(10, params.colDef["cellEditorParams"]["maxLength"]) - (parseFloat(1) / Math.pow(10, params.colDef["cellEditorParams"]["decimal"])))), // 최소값
                max:    // max 값 설정한 경우에는 해당 값을 넣고, 아니면 maxLength 로 처리. 이도 없으면 10자리 숫자로 처리.
                        // 총 9자리 중 3자리가 소수점이면 정수부는 6자리.
                        // 위 예시의 경우, 최대값은 10의 6제곱 - 1 / (10의 6제곱) 이다.
                        (params.colDef["cellEditorParams"]["max"] != null)
                      ? params.colDef["cellEditorParams"]["max"]
                      : (Math.pow(10, params.colDef["cellEditorParams"]["maxLength"]) - (parseFloat(1) / Math.pow(10, params.colDef["cellEditorParams"]["decimal"]))), // 최대값
                scale: params.colDef["cellEditorParams"]["decimal"],    // 소수점 자리수
                thousandsSeparator: '',         // 천단위 콤마(다른 문자열 가능)
                padFractionalZeros: false,      // 소수점이 없어도 자리수만큼 0 채우는 옵션 (false: 사용하지 않음)
                normalizeZeros: true,           // appends or removes zeros at ends...?
                radix: '.',                     // 소수점 문자열
                mapToRadix: ['.']               // 소수점을 입력할 키 ("." 키를 입력시 입력. "/" 이라고 하면 "/" 입력시 자동으로 소수점이 입력됨)
            });
        }
        MaskingEditor.prototype.getGui = function(params) {
            return this.eInput;
        }
        MaskingEditor.prototype.afterGuiAttached = function(params) {
            this.eInput.focus();
        }
        MaskingEditor.prototype.getValue = function(params) {
            return this.eInput.maskObj.unmaskedValue;
        }
        MaskingEditor.prototype.destroy = function(params) {}
        MaskingEditor.prototype.isPopup = function(params) {
            return false;
        }

        return MaskingEditor;
    }
}

var GridCustomFilter = {
    getSelectFloatingFilterComponent : function() {
        function SelectFloatingFilter() {
        }

        SelectFloatingFilter.prototype.init = function(params) {
            console.log(params);
            this.eGui = document.createElement('div');
            this.eGui.innerHTML = '<select><option value="" selected="selected">선택</option><option value="Y">예</option><option value="N">아니오</option></select>';
            this.currentValue = null;
            this.eFilterInput = this.eGui.querySelector('select');
            this.eFilterInput.style.color = params.color;
            var that = this;

            function onInputBoxChanged() {
                if (that.eFilterInput.value === '') {
                    // Remove the filter
                    params.parentFilterInstance(function(instance) {
                        instance.onFloatingFilterChanged(null, null);
                    });
                    return;
                }

                that.currentValue = that.eFilterInput.value;
                params.parentFilterInstance(function(instance) {
                    instance.onFloatingFilterChanged('equals', that.currentValue);
                });
            }

            this.eFilterInput.addEventListener('change', onInputBoxChanged);
        };

        SelectFloatingFilter.prototype.onParentModelChanged = function(parentModel) {
            // When the filter is empty we will receive a null message her
            if (!parentModel) {
                this.eFilterInput.value = '';
                this.currentValue = null;
            } else {
                this.eFilterInput.value = parentModel.filter + '';
                this.currentValue = parentModel.filter;
            }
        };

        SelectFloatingFilter.prototype.getGui = function() {
            return this.eGui;
        };

        return SelectFloatingFilter;
    }
}
