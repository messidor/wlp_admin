class ChunkUpload {

    /**
     * 생성자
     */
    constructor(_fileObj) {
        this.onProcessFunc = function() {};
        this.onSuccessFunc = function() {};
        this.onProcErrorFunc = function() {};
        this.onFinalErrorFunc = function() {};
        this.onErrorFunc = function() {};
        this.onBeforeFileChange = function() {};
        this.onAfterFileChange = function() {};
        this.onNoFileSelected = function() {};
        this.onInvalidExtension = function() {};
        this.onFileSizeExceed = function() {};
        this.param = {};
        this.url = "";
        this.blockSize = 1024 * 35;
        this.maxFileSize = 50 * 1024 * 1024;
        this.uploadFileExt = "pdf|jpg|jpeg|png|gif|hwp|hwpx|xls|xlsx";
        
        this.quality = [
            {"min" : 0, "max": 5, "qty": 1},
            {"min" : 5, "max": 10, "qty": 0.7},
            {"min" : 10, "max": 15, "qty": 0.6},
            {"min" : 15, "max": 20, "qty": 0.4},
            {"min" : 20, "max": 30, "qty": 0.2},
        ];
        
        // private variables for functions
        this._fileParams = [];
        this._base64File = "";
        this._curIdx = 0;
        this._totalIdx = 0;
        this._curSize = 0;
        this._totalSize = 0;
        this._fileUUID = "";
        this._updFileName = "";

        if(typeof(_fileObj) != 'undefined' && _fileObj != null) {
            let _that = this;
            _that.fileObj = _fileObj;
            
            let splitted = _that.uploadFileExt.split("|");
            let extStr = "";
            for(let i = 0; i < splitted.length; i++) {
                extStr += (i == 0 ? "" : ", ") + "." + splitted[i];
            }
            
            _that.fileObj.accept = extStr;
        } else if(_fileObj == null) {
            console.log("File object does not exist.");
            this.fileObj = null;
        } else {
            this.fileObj = null;
        }
    }

    get getFileObject() {
        return this.fileObj;
    }

    /**
     * document.getElementById 로 가지고 올 수 있는 input type="file" 객체
     * @param {HTMLInputElement} _blockSize file 객체
     */
    set setFileObject(_fileObj) {
        let _that = this;
        _that.fileObj = _fileObj;
        _that.fileExtChange();
    }

    get getBlockSize() {
        return this.blockSize;
    }

    /**
     * byte단위 chunk size를 결정한다.
     * @param {number} _blockSize byte 단위
     */
    set setBlockSize(_blockSize) {
        this.blockSize = _blockSize;
    }
    
    fileExtChange() {
        let _that = this;
        if(_that.fileObj != null) {
            let splitted = _that.uploadFileExt.split("|");
            let extStr = "";
            for(let i = 0; i < splitted.length; i++) {
                extStr += (i == 0 ? "" : ", ") + "." + splitted[i];
            }
            _that.fileObj.accept = extStr;
        } else {
            console.log("File object does not exist.");
        }
    }

    addFileEvent() {
        let _that = this;
        if(_that.fileObj == null) {
            console.log("ChunkUpload: file object is null. use setFileObject function to set element.");
            return;
        }
        _that.fileExtChange();
        
        _that.fileObj.onchange = function(e1) {
            
            _that._curIdx = 0;
            _that._fileParams = [];
            _that._base64File = "";
            _that._curIdx = 0;
            _that._totalIdx = 0;
            _that._curSize = 0;
            _that._totalSize = 0;
            _that._fileUUID = "";
//            _that._fileDecode = "";
            
            let fileReader = new FileReader();
            fileReader.readAsDataURL(e1.target.files[0]);
            
            // file extension
            let extStr = "(.*?)\.(" + _that.uploadFileExt.toLowerCase() + ")$";
            let extRegExp = new RegExp(extStr);
            if(!extRegExp.test(e1.target.files[0].name.toLowerCase())) {
                _that.fileObj.value = "";
                _that.onInvalidExtension(null, e1);
                return false;
            }
            
            // file size
            let updFileSize = e1.target.files[0].size;
            if(updFileSize > _that.maxFileSize) {
                _that.fileObj.value = "";
                _that.onFileSizeExceed(null, e1);
                return false;
            }
            
            _that._updFileName = e1.target.files[0].name;
            
            fileReader.onload = function(e2) {
                let evtRes = _that.onBeforeFileChange.call(null, e2);
                
                if(evtRes === false) {
                    _that.fileObj.value = "";
                    return false;
                }
                //_that._base64File = e.target.result; // base64 인코딩된 값
                
                // 내부적으로 이미지파일만 압축 가능하기 때문에 모든 이미지 파일의 확장자를 등록한다.
                // 업로드 가능 확장자와는 관련이 없다.
                let imgExt = new RegExp("(.*?)\.(jpg|jpeg|bmp|gif|png)$");
                
                if(updFileSize >= _that.quality[1]["min"] * 1024 * 1024 && imgExt.test(_that._updFileName.toLowerCase())) {
                    // 이미지 파일이고, 용량이 일정 용량 이상 되면 압축을 시도한다.
                    let imgQty = 0.0;
                    
                    for(let i = 1; i < _that.quality.length; i++) {
                        if(updFileSize >= _that.quality[i]["min"] * 1024 * 1024 && updFileSize < _that.quality[i]["max"] * 1024 * 1024) {
                            imgQty = _that.quality[i]["qty"];
                            break;
                        }
                    }
                    
                    new Compressor(_that.fileObj.files[0], {
                        quality: imgQty,
                        convertTypes: ['image/png', 'image/webp'],
                        
                        success: function(result) {
                            const formData = new FormData();
                            formData.append('file', result, result.name);
                            
                            _that._totalSize = result.size;
                            
                            let reader = new FileReader();
                            reader.readAsDataURL(result); 
                            reader.onloadend = function(readerEvtObj) {
                                _that._base64File = reader.result;
                                _that._fileParams = [];
                                let fileStr = _that._base64File.substring(_that._base64File.indexOf(";base64,") + 8);
                                let curSize = 0;
                                while(curSize < fileStr.length) {
                                    let piece = fileStr.substr(curSize, _that.blockSize);
                                    _that._fileParams.push(piece);
                                    curSize += _that.blockSize;
                                }
                                
                                _that._totalIdx = _that._fileParams.length;
                                _that._fileUUID = getUuidV4(); // in framework.js
                                // afterFileChange 이벤트
                                _that.onAfterFileChange.call(null, readerEvtObj);
                            }
                        },
                        error: function(err) {
                            console.log(err);
                        }
                    });
                } else {
                    // 이미지 파일이 아니면 압축이 불가능하므로 그냥 올리도록 한다.
                    _that._base64File = e2.target.result; // base64 인코딩된 값
                    _that._fileParams = [];
                    let fileStr = _that._base64File.substring(_that._base64File.indexOf(";base64,") + 8);
                    _that._totalSize = fileStr.length;
                    let curSize = 0;
                    while(curSize < _that._totalSize) {
                        let piece = fileStr.substr(curSize, _that.blockSize);
                        _that._fileParams.push(piece);
                        curSize += _that.blockSize;
                    }
                    
                    _that._totalIdx = _that._fileParams.length;
                    _that._fileUUID = getUuidV4(); // in common.js
                    
                    _that.onAfterFileChange.call(null, e2);
                }
            }
        }
    }

    goUpload() {
        let _that = this;
        
        if(typeof(_that.fileObj) == 'undefined' || _that.fileObj == null || _that.fileObj.files.length < 1) {
            // 파일을 선택하지 않음
            _that.onNoFileSelected.call(null, _that.fileObj);
            return;
        }
        
        // upload function
        _that.param["fileCont"] = _that._fileParams[_that._curIdx];
        _that.param["curIdx"] = _that._curIdx;
        _that.param["totalIdx"] = _that._totalIdx;
        _that.param["totalSize"] = _that._totalSize;
        _that.param["blockSize"] = _that.blockSize;
        _that.param["fileName"] = _that.fileObj.files[0].name;
        _that.param["uuid"] = _that._fileUUID;
        //_that.param["uploadFileExt"] = _that.uploadFileExt;
        _that.param["maxFileSize"] = _that.maxFileSize;

        $.ajax({
            type : 'POST',
            dataType : 'json',
            async : true,
            cache : false,
            url : _that.url,
            data : _that.param,
            success: function(result, textStatus, jqXHR) {

                if(result.count == 1) {
                    // 정상 완료
                    ++_that._curIdx;
                    let pcnt = _that._curIdx > _that._totalIdx ? "100" : (_that._curIdx * 100 / _that._totalIdx).toFixed(2);
                    // successFunc 이벤트 : 정상 완료 이벤트
                    _that.onSuccessFunc.call(null, pcnt, _that._curIdx, _that._totalIdx, result, textStatus, jqXHR);
                    _that.fileObj.value = "";
                    _that._curIdx = 0;
                    _that._fileParams = [];
                    _that._base64File = "";
                    _that._curIdx = 0;
                    _that._totalIdx = 0;
                    _that._curSize = 0;
                    _that._totalSize = 0;
                    _that._fileUUID = "";
                } else if(result.count == 2) {
                    // 정상 진행중
                    ++_that._curIdx;
                    let pcnt = _that._curIdx > _that._totalIdx ? "100" : (_that._curIdx * 100 / _that._totalIdx).toFixed(2);
                    // processFunc 이벤트 : 업로드 정상 진행 도중 발생하는 이벤트
                    _that.onProcessFunc.call(null, pcnt, _that._curIdx, _that._totalIdx, result, textStatus, jqXHR);
                    _that.goUpload();
                } else if(result.count == -1000) {
                    // 진행 실패
                    // procErrorFunc 이벤트 : chunk 업로드 도중의 오류
                    _that.onProcErrorFunc.call(null, _that._curIdx, _that._totalIdx, result, textStatus, jqXHR);
                    console.log("ChunkUpload :: Not all chunk uploaded(" + _that._curIdx + " / " + _that._totalIdx + ")");
                    _that.fileObj.value = "";
                    _that._curIdx = 0;
                    _that._fileParams = [];
                    _that._base64File = "";
                    _that._curIdx = 0;
                    _that._totalIdx = 0;
                    _that._curSize = 0;
                    _that._totalSize = 0;
                    _that._fileUUID = "";
                } else if(result.count == -1500) {
                    // 파일 확장자가 허용되지 않은 경우
                    _that.onInvalidExtension.call(null, _that.fileObj);
                    console.log("ChunkUpload :: File Extension not allowed.");
                    _that.fileObj.value = "";
                    _that._curIdx = 0;
                    _that._fileParams = [];
                    _that._base64File = "";
                    _that._curIdx = 0;
                    _that._totalIdx = 0;
                    _that._curSize = 0;
                    _that._totalSize = 0;
                    _that._fileUUID = "";
                } else if(result.count == -1510) {
                    // 파일 크기가 허용되지 않은 경우
                    _that.onFileSizeExceed.call(null, _that.fileObj);
                    console.log("ChunkUpload :: File size limit is exceeded.");
                    _that.fileObj.value = "";
                    _that._curIdx = 0;
                    _that._fileParams = [];
                    _that._base64File = "";
                    _that._curIdx = 0;
                    _that._totalIdx = 0;
                    _that._curSize = 0;
                    _that._totalSize = 0;
                    _that._fileUUID = "";
                } else if(result.count == -2000) {
                    // Exception
                    // finalErrorFunc 이벤트 : 모든 chunk 업로드 되었으나, 마지막에 오류 발생
                    _that.onFinalErrorFunc.call(null, _that._curIdx, _that._totalIdx, result, textStatus, jqXHR);
                    console.log("ChunkUpload :: Last chunk returns error.");
                    _that.fileObj.value = "";
                    _that._curIdx = 0;
                    _that._fileParams = [];
                    _that._base64File = "";
                    _that._curIdx = 0;
                    _that._totalIdx = 0;
                    _that._curSize = 0;
                    _that._totalSize = 0;
                    _that._fileUUID = "";
                } else {
                    // 기타 리턴 (다른 문제)
                    _that.onErrorFunc.call(null, _that._curIdx, _that._totalIdx, result, textStatus, jqXHR);
                    _that.fileObj.value = "";
                    _that._curIdx = 0;
                    _that._fileParams = [];
                    _that._base64File = "";
                    _that._curIdx = 0;
                    _that._totalIdx = 0;
                    _that._curSize = 0;
                    _that._totalSize = 0;
                    _that._fileUUID = "";
                }
            },
            error: function(data, textStatus, errorThrown) {
                _that.onErrorFunc.call(null, _that._curIdx, _that._totalIdx, data, textStatus, errorThrown);
                _that.fileObj.value = "";
                _that._curIdx = 0;
                _that._fileParams = [];
                _that._base64File = "";
                _that._curIdx = 0;
                _that._totalIdx = 0;
                _that._curSize = 0;
                _that._totalSize = 0;
                _that._fileUUID = "";
            }
        });
    }
}