class ChunkUploadMulti {

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
        this.onFileCountLimitExceed = function() {};
        this.param = {};
        this.url = "";
        this.blockSize = 1024 * 35;
        this.maxFileSize = 50 * 1024 * 1024;
        this.uploadFileExt = "pdf|jpg|jpeg|png|gif|hwp|hwpx|xls|xlsx";
        this.filesLimit = 5; // 파일 업로드 제한 개수 (해당 숫자 이하 가능)
        
        this.quality = [
            {"min" : 0, "max": 5, "qty": 1},
            {"min" : 5, "max": 10, "qty": 0.7},
            {"min" : 10, "max": 15, "qty": 0.6},
            {"min" : 15, "max": 20, "qty": 0.4},
            {"min" : 20, "max": 30, "qty": 0.2},
        ];
        
        // 업로드 파일 정보(형식. JSON.parse(JSON.stringify(obj)) 메서드로 deep copy 하여 사용하는 용도)
        // _uploadFileInfo 에 추가
        this._uploadFileSingleInfo = {
            fileName: "",               // 파일명 (클라이언트에서 업로드한 이름)
            base64: "",                 // 전체 인코딩 데이터
            encData: [],                // Block Size별로 잘라서 인코딩된 데이터(chunks)
            uuid: "",                   // 파일의 UUID
            curIdx: 0,                  // 현재 chunk index
            totalIdx: 0,                // 전체 chunk 개수
            curSize: 0,                 // 현재 업로드 중인 내용의 크기
            totalSize: 0,               // 전체 크기
            ext: "",                    // 확장자
            fileKey: "",                // FILE_KEY
            fileRelKey: ""              // FILE_REL_KEY
        };
        this._curFileIdx = 0;           // 현재 업로드 중인 파일 번호
        this._uploadFileInfo = [];      // 업로드 파일 정보 (파일이 늘어나면 늘어날 수록 json이 추가되는 방식)
        this._curChunks = 0;            // 현재 chunk
        this._totalChunks = 0;          // 전체 chunk 개수
        this._totalFileCount = 0;       // 전체 파일 개수
        this._fileRelKey = "";          // 생성된 파일 릴레이션 키
        this._readyFilesCount = 0;      // 준비된 파일 개수
        this._eventRunCount = 0;        // 이벤트 수행 개수
        
        this._isAllStop = false;        // 전체 중지를 위한 flag
        this._isProcess = true;         // 특정 프로세스 진행을 위한 flag

        // file 객체 확인
        if(typeof(_fileObj) != 'undefined' && _fileObj != null) {
            let self = this;
            self.fileObj = _fileObj;
            
            let splitted = self.uploadFileExt.split("|");
            let extStr = "";
            for(let i = 0; i < splitted.length; i++) {
                extStr += (i == 0 ? "" : ", ") + "." + splitted[i];
            }
            
            // 파일 선택 확장자 변경
            self.fileObj.accept = extStr;
            // 파일 멀티 선택되게 변경
            self.fileObj.multiple = true;
        } else if(_fileObj == null) {
            if(console) {
                console.log("File object does not exist.");
            }
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
        let self = this;
        self.fileObj = _fileObj;
        self.fileExtChange();
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

    get getCurFileIdx() {
        return this._curFileIdx;
    }

    getUploadFileInfo() {
        return this._uploadFileInfo;
    }

    getFilesLimit() {
        return this.filesLimit;
    }

    setFilesLimit(fLimit) {
        if(typeof(fLimit) == 'undefined' || fLimit == null) {
            console.log("FilesLimit should not be null or undefined.");
            return;
        }

        if(typeof(fLimit) != 'number') {
            console.log("FilesLimit should be number.");
            return;
        }

        if(fLimit < 2) {
            console.log("FilesLimit should be same or more than 1.");
            return;
        }
        this.filesLimit = fLimit;
    }
    
    fileExtChange() {
        let self = this;
        if(self.fileObj != null) {
            let splitted = self.uploadFileExt.split("|");
            let extStr = "";
            for(let i = 0; i < splitted.length; i++) {
                extStr += (i == 0 ? "" : ", ") + "." + splitted[i];
            }
            // 파일 선택 확장자 변경
            self.fileObj.accept = extStr;
            // 파일 멀티 선택되게 변경
            self.fileObj.multiple = true;
        } else {
            console.log("File object does not exist.");
        }
    }

    addFileEvent() {
        let self = this;
        if(self.fileObj == null) {
            console.log("ChunkUpload: file object is null. use setFileObject function to set element.");
            return;
        }
        self.fileExtChange();
        
        self.fileObj.onchange = function(e1) {
            
            self._curFileIdx = 0;
            self._uploadFileInfo = [];
            self._curChunks = 0;
            self._totalChunks = 0;
            self._totalFileCount = e1.target.files.length;
            self._fileRelKey = "";
            self._readyFilesCount = 0;
            self._eventRunCount = 0;
            self._isAllStop = false;
            self._isProcess = true;

            let fileList = [];

            if(e1.target.files.length > 0) {
                for(let i = 0; i < e1.target.files.length; i++) {
                    fileList.push(e1.target.files[i].name);
                }
            }

            // 업로드 전처리 이벤트 실행. false 리턴시 전처리 하지 않도록 함
            let evtRes = self.onBeforeFileChange.call(null, e1, fileList);
            if(evtRes === false) {
                self.fileObj.value = "";
                return false;
            }
            
            if(self.filesLimit < e1.target.files.length) {
                self.onFileCountLimitExceed(null);
                self.fileObj.value = null;
                return false;
            }

            if(e1.target.files.length > 0) {
            
                for(let i = 0; i < e1.target.files.length; i++) {

                    // 파일 정보 1개 생성
                    self._uploadFileInfo.push(JSON.parse(JSON.stringify(self._uploadFileSingleInfo)));

                    let fileReader = new FileReader();
                    fileReader.readAsDataURL(e1.target.files[i]);
                    
                    // file extension
                    let extStr = "(.*?)\.(" + self.uploadFileExt + ")$";
                    let extRegExp = new RegExp(extStr);
                    if(!extRegExp.test(e1.target.files[i].name.toLowerCase())) {
                        self.fileObj.value = "";
                        // 파일 객체, 파일명 넣어서 리턴
                        self.onInvalidExtension(null, e1, e1.target.files[i].name);
                        return false;
                    }
                    
                    // file size
                    let updFileSize = e1.target.files[i].size;
                    if(updFileSize > self.maxFileSize) {
                        self.fileObj.value = "";
                        self.onFileSizeExceed(null, e1, e1.target.files[i].name);
                        return false;
                    }
                    
                    self._uploadFileInfo[i]["fileName"] = e1.target.files[i].name;
                    self._uploadFileInfo[i]["ext"] = e1.target.files[i].name.substring(e1.target.files[i].name.lastIndexOf(".") + 1, e1.target.files[i].name.length);
                    
                    fileReader.imageIndex = i;
                    fileReader.imageFileName = e1.target.files[i].name;
                    
                    fileReader.onloadend = function(e2) {
                        // 내부적으로 이미지파일만 압축 가능하기 때문에 모든 이미지 파일의 확장자를 등록한다.
                        // 업로드 가능 확장자와는 관련이 없다.
                        let imgExt = new RegExp("(.*?)\.(jpg|jpeg|bmp|gif|png)$");
                        
                        if(updFileSize >= self.quality[1]["min"] * 1024 * 1024 && imgExt.test(self._uploadFileInfo[e2.target.imageIndex]["fileName"].toLowerCase())) {
                            // 이미지 파일이고, 용량이 일정 용량 이상 되면 압축을 시도한다.
                            let imgQty = 0.0;
                            
                            // 압축해야 할 quality 확인
                            for(let j = 1; j < self.quality.length; j++) {
                                if(updFileSize >= self.quality[j]["min"] * 1024 * 1024 && updFileSize < self.quality[j]["max"] * 1024 * 1024) {
                                    imgQty = self.quality[j]["qty"];
                                    break;
                                }
                            }
                            
                            new Compressor(self.fileObj.files[e2.target.imageIndex], {
                                quality: imgQty,
                                convertTypes: ['image/png', 'image/webp'],
                                success: function(result) {
                                    
                                    const formData = new FormData();
                                    formData.append('file', result, result.name);
                                    
                                    // 파일 이름으로 인덱스를 찾는다..
                                    let idx = 0;
                                    for(let k = 0; k < self._uploadFileInfo.length; k++) {
                                        if(self._uploadFileInfo[k]["fileName"] === e2.target.imageFileName && self._uploadFileInfo[k]["base64"].length < 1) {
                                            idx = k;
                                            break;
                                        }
                                    }
                                    
                                    self._uploadFileInfo[idx]["totalSize"] = result.size;
                                    // self._totalSize = result.size;
                                    
                                    let reader = new FileReader();
                                    reader.readAsDataURL(result);
                                    reader.imgIdx = idx; // 현재 이미지 인덱스를 미리 넘겨준다..
                                    reader.onloadend = function(readerEvtObj) {
                                        let base64File = reader.result;
                                        self._uploadFileInfo[readerEvtObj.target.imgIdx]["base64"] = base64File;
                                        self._uploadFileInfo[readerEvtObj.target.imgIdx]["encData"] = [];
                                        let fileStr = base64File.substring(base64File.indexOf(";base64,") + 8);
                                        let curSize = 0;
                                        while(curSize < fileStr.length) {
                                            let piece = fileStr.substr(curSize, self.blockSize);
                                            self._uploadFileInfo[readerEvtObj.target.imgIdx]["encData"].push(piece);
                                            curSize += self.blockSize;
                                            ++self._totalChunks;
                                        }
                                        
                                        self._uploadFileInfo[readerEvtObj.target.imgIdx]["totalIdx"] = self._uploadFileInfo[readerEvtObj.target.imgIdx]["encData"].length;
                                        self._uploadFileInfo[readerEvtObj.target.imgIdx]["uuid"] = getUuidV4(); // in framework.js
                                        // afterFileChange 이벤트
                                        console.log("file(Compressor) is ready.");
                                        // self.onAfterFileChange.call(null, readerEvtObj);
                                        ++self._readyFilesCount;
                                        ++self._eventRunCount;
                                        if(self._readyFilesCount >= self._totalFileCount) {
                                            self.onAfterFileChange.call(null, e1, fileList);
                                        }
                                    }
                                },
                                error: function(err) {
                                    console.log(err);
                                }
                            });
                        } else {
                            // 이미지 파일이 아니면 압축이 불가능하므로 그냥 올리도록 한다.
                            let base64File = e2.target.result; // base64 인코딩된 값
                            self._uploadFileInfo[e2.target.imageIndex]["base64"] = base64File;
                            self._uploadFileInfo[e2.target.imageIndex]["encData"] = [];
                            let fileStr = base64File.substring(base64File.indexOf(";base64,") + 8);
                            self._uploadFileInfo[e2.target.imageIndex]["totalSize"] = fileStr.length;
                            let curSize = 0;
                            while(curSize < self._uploadFileInfo[e2.target.imageIndex]["totalSize"]) {
                                let piece = fileStr.substr(curSize, self.blockSize);
                                self._uploadFileInfo[e2.target.imageIndex]["encData"].push(piece);
                                curSize += self.blockSize;
                                ++self._totalChunks;
                            }
                            
                            self._uploadFileInfo[e2.target.imageIndex]["totalIdx"] = self._uploadFileInfo[e2.target.imageIndex]["encData"].length;
                            self._uploadFileInfo[e2.target.imageIndex]["uuid"] = getUuidV4(); // in framework.js
                            
                            console.log("file is ready.");
                            ++self._eventRunCount;
                            ++self._readyFilesCount;
                            if(self._readyFilesCount >= self._totalFileCount) {
                                self.onAfterFileChange.call(null, e1, fileList);
                            }
                        }
                    }
                } // for(let i = 0; i < e1.target.files.length; i++)
            } // if(e1.target.files.length > 0)
        }
    }

    goUpload() {
        let self = this;
        let cIdx = self._curFileIdx;
        
        if(cIdx > self._uploadFileInfo.length - 1) {
            cIdx = self._uploadFileInfo.length - 1;
        }
        
        if(typeof(self.fileObj) == 'undefined' || self.fileObj == null || self.fileObj.files.length < 1) {
            // 파일을 선택하지 않음
            self.onNoFileSelected.call(null, self.fileObj);
            return;
        }

        let fileKeys = "";
        for(let k = 0; k < self._uploadFileInfo.length; k++) {
            if(self._uploadFileInfo[k]["fileKey"].length > 0) {
                fileKeys += (k == 0 ? "" : ",") + self._uploadFileInfo[k]["fileKey"];
            }
        }
        
        // upload function
        self.param["fileCont"] = self._uploadFileInfo[cIdx]["encData"][self._uploadFileInfo[cIdx]["curIdx"]];
        self.param["curIdx"] = self._uploadFileInfo[cIdx]["curIdx"];
        self.param["totalIdx"] = self._uploadFileInfo[cIdx]["totalIdx"];
        self.param["totalSize"] = self._uploadFileInfo[cIdx]["totalSize"];
        self.param["fileName"] = self._uploadFileInfo[cIdx]["fileName"];
        self.param["uuid"] = self._uploadFileInfo[cIdx]["uuid"];
        self.param["uploadFileExt"] = self._uploadFileInfo[cIdx]["ext"];

        self.param["curFileIdx"] = self._curFileIdx;
        self.param["totalFileCount"] = self._totalFileCount;
        self.param["fileRelKey"] = self.param["fileRelKey"] == "" ? self._fileRelKey : self.param["fileRelKey"];
        self.param["fileKey"] = fileKeys;
        self.param["maxFileSize"] = self.maxFileSize;
        self.param["blockSize"] = self.blockSize;

        $.ajax({
            type : 'POST',
            dataType : 'json',
            async : true,
            cache : false,
            url : self.url,
            data : self.param,
            success: function(result, textStatus, jqXHR) {

                if(result.count == 1) {
                    // 정상 완료
                    ++self._uploadFileInfo[cIdx]["curIdx"];
                    ++self._curChunks;
                    if(self._uploadFileInfo[cIdx]["curIdx"] >= self._uploadFileInfo[cIdx]["totalIdx"]) {
                        ++self._curFileIdx;
                        cIdx = (self._curFileIdx > self._uploadFileInfo.length - 1) ? self._uploadFileInfo.length - 1 : self._curFileIdx;
                    }
                    let pcnt = self._uploadFileInfo[cIdx]["curIdx"] > self._uploadFileInfo[cIdx]["totalIdx"] ? "100" :
                                            (self._uploadFileInfo[cIdx]["curIdx"] * 100 / self._uploadFileInfo[cIdx]["totalIdx"]).toFixed(2);
                    let pcnt_all = self._curChunks > self._totalChunks ? "100" : (self._curChunks * 100 / self._totalChunks).toFixed(2);
                    // successFunc 이벤트 : 정상 완료 이벤트
                    self.onSuccessFunc.call(null, pcnt, self._uploadFileInfo[cIdx]["curIdx"], self._uploadFileInfo[cIdx]["totalIdx"], result, textStatus, jqXHR, pcnt_all, self._curChunks, self._totalChunks);
                    self._uploadFileInfo[cIdx]["curIdx"] = 0;
                    self.fileObj.value = "";
                    self._curFileIdx = 0;
                    self._uploadFileInfo = [];
                    self._curChunks = 0;
                    self._totalChunks = 0;
                    self._totalFileCount = 0;
                    self._fileRelKey = "";
                    self._readyFilesCount = 0;
                    self._eventRunCount = 0;
                    self._isAllStop = false;
                    self._isProcess = true;
                } else if(result.count == 2 || result.count == 3) {
                    // 정상 진행중
                    if(result.count == 3) {
                        // 파일 한개가 마무리 되면 릴레이션 키를 받아와서 저장한다.
                        // 이 값을 계속 보내서 릴레이션 키 중복 생성을 막는다.
                        self._fileRelKey = result["data"]["newFileRelKey"];
                        self._uploadFileInfo[cIdx]["fileKey"] = result["data"]["newFileKey"];
                    }
                    ++self._uploadFileInfo[cIdx]["curIdx"];
                    ++self._curChunks;
                    if(self._uploadFileInfo[cIdx]["curIdx"] >= self._uploadFileInfo[cIdx]["totalIdx"]) {
                        ++self._curFileIdx;
                        cIdx = (self._curFileIdx > self._uploadFileInfo.length - 1) ? self._uploadFileInfo.length - 1 : self._curFileIdx;
                    }
                    let pcnt = self._uploadFileInfo[cIdx]["curIdx"] > self._uploadFileInfo[cIdx]["totalIdx"] ? "100" :
                                            (self._uploadFileInfo[cIdx]["curIdx"] * 100 / self._uploadFileInfo[cIdx]["totalIdx"]).toFixed(2);
                    let pcnt_all = self._curChunks > self._totalChunks ? "100" : (self._curChunks * 100 / self._totalChunks).toFixed(2);
                    // processFunc 이벤트 : 업로드 정상 진행 도중 발생하는 이벤트
                    self.onProcessFunc.call(null, pcnt, self._uploadFileInfo[cIdx]["curIdx"], self._uploadFileInfo[cIdx]["totalIdx"], result, textStatus, jqXHR, pcnt_all, self._curChunks, self._totalChunks);
                    self.goUpload();
                } else if(result.count == -1000) {
                    // 진행 실패
                    // procErrorFunc 이벤트 : chunk 업로드 도중의 오류
                    self.onProcErrorFunc.call(null, self._uploadFileInfo[cIdx]["curIdx"], self._uploadFileInfo[cIdx]["totalIdx"], result, textStatus, jqXHR);
                    console.log("ChunkUpload :: Not all chunk uploaded(" + self._uploadFileInfo[cIdx]["curIdx"] + " / " + self._uploadFileInfo[cIdx]["totalIdx"] + ")");
                    self.fileObj.value = "";
                    self._curFileIdx = 0;
                    self._uploadFileInfo = [];
                    self._curChunks = 0;
                    self._totalChunks = 0;
                    self._totalFileCount = 0;
                    self._fileRelKey = "";
                    self._readyFilesCount = 0;
                    self._eventRunCount = 0;
                    self._isAllStop = false;
                    self._isProcess = true;
                } else if(result.count == -1500) {
                    // 파일 확장자가 허용되지 않은 경우
                    self.onInvalidExtension.call(null, self.fileObj);
                    console.log("ChunkUpload :: File Extension not allowed.");
                    self.fileObj.value = "";
                    self._curFileIdx = 0;
                    self._uploadFileInfo = [];
                    self._curChunks = 0;
                    self._totalChunks = 0;
                    self._totalFileCount = 0;
                    self._fileRelKey = "";
                    self._readyFilesCount = 0;
                    self._eventRunCount = 0;
                    self._isAllStop = false;
                    self._isProcess = true;
                } else if(result.count == -1510) {
                    // 파일 크기가 허용되지 않은 경우
                    self.onFileSizeExceed.call(null, self.fileObj);
                    console.log("ChunkUpload :: File size limit is exceeded.");
                    self.fileObj.value = "";
                    self._curFileIdx = 0;
                    self._uploadFileInfo = [];
                    self._curChunks = 0;
                    self._totalChunks = 0;
                    self._totalFileCount = 0;
                    self._fileRelKey = "";
                    self._readyFilesCount = 0;
                    self._eventRunCount = 0;
                    self._isAllStop = false;
                    self._isProcess = true;
                } else if(result.count == -2000) {
                    // Exception
                    // finalErrorFunc 이벤트 : 모든 chunk 업로드 되었으나, 마지막에 오류 발생
                    self.onFinalErrorFunc.call(null, self._uploadFileInfo[cIdx]["curIdx"], self._uploadFileInfo[cIdx]["totalIdx"], result, textStatus, jqXHR);
                    console.log("ChunkUpload :: Last chunk returns error.");
                    self.fileObj.value = "";
                    self._curFileIdx = 0;
                    self._uploadFileInfo = [];
                    self._curChunks = 0;
                    self._totalChunks = 0;
                    self._totalFileCount = 0;
                    self._fileRelKey = "";
                    self._readyFilesCount = 0;
                    self._eventRunCount = 0;
                    self._isAllStop = false;
                    self._isProcess = true;
                } else {
                    // 기타 리턴 (다른 문제)
                    self.onErrorFunc.call(null, self._uploadFileInfo[cIdx]["curIdx"], self._uploadFileInfo[cIdx]["totalIdx"], result, textStatus, jqXHR);
                    self.fileObj.value = "";
                    self._curFileIdx = 0;
                    self._uploadFileInfo = [];
                    self._curChunks = 0;
                    self._totalChunks = 0;
                    self._totalFileCount = 0;
                    self._fileRelKey = "";
                    self._readyFilesCount = 0;
                    self._eventRunCount = 0;
                    self._isAllStop = false;
                    self._isProcess = true;
                }
            },
            error: function(data, textStatus, errorThrown) {
                self.onErrorFunc.call(null, self._uploadFileInfo[cIdx]["curIdx"], self._uploadFileInfo[cIdx]["totalIdx"], data, textStatus, errorThrown);
                self.fileObj.value = "";
                self._curFileIdx = 0;
                self._uploadFileInfo = [];
                self._curChunks = 0;
                self._totalChunks = 0;
                self._totalFileCount = 0;
                self._fileRelKey = "";
                self._readyFilesCount = 0;
                self._eventRunCount = 0;
                self._isAllStop = false;
                self._isProcess = true;
            }
        });
    }
}