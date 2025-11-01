// 언어셋 javascript 변수가 없는 경우를 대비함..
if(typeof(LangData) == 'undefined') {
    LangData = {
        get: function(p_Code) {
            return p_Code;
        }
    }
}

$(function() {

    $.fn.multiUpload = function(param) {

        var obj = $(this);
        var upload_div = obj.attr("id");
        var deny_file_name = /[\\\/\:\*\?\"\<\>\|\0]/gi;

        obj.data("upload_data", []);
        obj.data("upload_cleared", true);

        // url : 필수 (임시 저장 로직이 있는 url)
        // fileExt : 필수 (업로드 가능한 파일 확장자)
        // uploadName : 필수 (서버에서 인식하는 파일 객체의 이름)
        // deleteUrl : 필수 (파일 1개 삭제하는 서버 로직이 있는 url)
        // deleteAllUrl : 필수 (업로드 한 모든 파일을 삭제하는 서버 로직이 있는 url)

        // 업로드 폴더 (기본 public/uploads/temp)
        param["uploadFolder"] = param["uploadFolder"] || "temp";
        // 데이터 저장 후 저장되는 폴더 (기본값 없음, 필수, /public/uploads/ 이후의 경로만 필요함. 양 끝의 슬러시(/) 기호는 필요 없음)
        param["realUploadFolder"] = param["realUploadFolder"] || "";
        // 추가 파라미터
        param["addParams"] = typeof(param["addParams"]) != 'undefined' ? param["addParams"] : {"_token" : $("meta[name='csrf-token']").attr("content"), "upload_folder" : param["uploadFolder"]};
        // 업로드 가능한 확장자
        param["fileExt"] = param["fileExt"] || "";
        // 개별 파일의 업로드 가능한 최대 크기 (500 MB 와 서버 설정 중 작은 값을 사용)
        param["maxFilesize"] = param["maxFilesize"] || (500 < g_ServerMaxUploadFileSize ? 500 : g_ServerMaxUploadFileSize);
        param["maxFilesize"] = param["maxFilesize"] < g_ServerMaxUploadFileSize ? param["maxFilesize"] : g_ServerMaxUploadFileSize; // 서버 설정과 파라미터로 입력한 값 중 작은 값을 사용
        // 한 번에 올릴 수 있는 최대 파일 갯수와 전체 올릴 수 있는 파일 갯수 (10개와 서버 설정중 작은 값을 사용)
        param["maxFiles"] = param["maxFiles"] || (10 < g_ServerMaxUploadFileCount ? 10 : g_ServerMaxUploadFileCount);
        param["maxFiles"] = param["maxFiles"] < g_ServerMaxUploadFileCount ? param["maxFiles"] : g_ServerMaxUploadFileCount; // 서버 설정과 파라미터로 입력한 값 중 작은 값을 사용
        // 멀티 업로드 여부 (기본 true)
        param["multiple"] = typeof(param["multiple"]) != 'boolean' ? true : param["multiple"];
        // 모두 성공적으로 올라갔을 때의 함수 (서버요청 결과와 업로드 된 파일 정보 전체를 파라미터로 받음)
        param["success"] = typeof(param["success"]) != 'function' ? function() {} : param["success"];
        // 업로드 도중 실패하는 경우
        param["error"] = typeof(param["error"]) != 'function' ? function() {} : param["error"];
        // 기존에 표시해야 할 파일이 있는 경우
        param["initFiles"] = param["initFiles"] || [];
        // file_rel_key 가 file_key 와 1:1 로 생성되는 경우 true, 아니면 false. 기본값은 false.
        param["singleRelation"] = typeof(param["singleRelation"]) != 'boolean' ? false : param["singleRelation"];

        // 삭제 관련 파라미터
        // 삭제시 필요한 파라미터
        param["deleteParams"] = param["deleteParams"] || {};
        // 1 개의 임시파일을 삭제하면 수행하는 URL (file_rel_key, file_key 를 받음) (필수)
        param["deleteUrl"] = param["deleteUrl"] || "";
        // 1 개의 실제파일을 삭제하면 수행하는 URL (file_rel_key, file_key 를 받음) (필수)
        param["deleteRealUrl"] = param["deleteRealUrl"] || "";
        // 모든 임시파일 삭제 후 수행하는 URL (file_rel_key 를 받음)
        param["deleteAllUrl"] = param["deleteAllUrl"] || "";
        // 1 개의 임시파일 삭제 후 수행하는 함수
        param["deleteSuccess"] = typeof(param["deleteSuccess"]) != 'function' ? function() {} : param["deleteSuccess"];
        // 모든 임시파일 삭제 후 수행하는 함수
        param["deleteAllSuccess"] = typeof(param["deleteAllSuccess"]) != 'function' ? function() {} : param["deleteAllSuccess"];
        // 1 개의 임시파일 삭제 실패시 수행하는 함수
        param["deleteError"] = typeof(param["deleteError"]) != 'function' ? function() {} : param["deleteError"];
        // 모든 임시파일 삭제 실패시 수행하는 함수
        param["deleteAllError"] = typeof(param["deleteAllError"]) != 'function' ? function() {} : param["deleteAllError"];

        // 파일 드랍시 수행하는 함수
        param["deleteAllError"] = typeof(param["deleteAllError"]) != 'function' ? function() {} : param["deleteAllError"];

        // 실제 파일 삭제 후 처리할 쿼리 ID
        param["query_id"] = param["query_id"] || "";
        // 실제 파일 삭제 후 실행할 컨트롤러 (query_id 가 있으면 controller 무시함)
        param["controller"] = param["controller"] || "";

        // 서버에 저장될 파일명 앞에 붙일 접두사 (언더바 등의 구분자는 직접 붙여야 함)
        param["fn_prefix"] = param["fn_prefix"] || "";
        // 서버에 저장될 파일명 뒤에 붙일 접미사 (언더바 등의 구분자는 직접 붙여야 함)
        param["fn_suffix"] = param["fn_suffix"] || "";

        // 토큰및 필수 파라미터는 미리 넣도록 함
        param["addParams"]["_token"] = $("meta[name='csrf-token']").attr("content");    // 토큰값
        param["addParams"]["upload_folder"] = param["uploadFolder"];                    // 업로드 폴더
        param["addParams"]["uploadName"] = param["uploadName"];                         // 업로드 이름 (request->file("") 에 사용할 이름)
        param["addParams"]["fileExt"] = param["fileExt"];                               // 업로드 가능 확장자 목록
        param["addParams"]["singleRelation"] = param["singleRelation"];                 // 1:1 혹은 1:N 관계

        param["addParams"]["fn_prefix"] = param["fn_prefix"];       // 파일명 접두사
        param["addParams"]["fn_suffix"] = param["fn_suffix"];       // 파일명 접미사

        // 접두사에서 사용할 수 없는 문자열 걸러냄
        if(param["fn_prefix"] != "") {
            if(deny_file_name.test(param["fn_prefix"])) {
                // 사용할 수 없는 문자열입니다.
                throw "(Prefix) The string cannot be used in file name. String : (" + element + ")";
            }
        }

        // 접미사에서 사용할 수 없는 문자열 걸러냄
        if(param["fn_suffix"] != "") {
            if(deny_file_name.test(param["fn_suffix"])) {
                throw "(Suffix) The string cannot be used in file name. String : (" + element + ")";
            } else if(param["fn_suffix"].lastIndexOf(".") == param["fn_suffix"].length - 1 && param["fn_suffix"].length > 0) {
                // 파일 이름의 마지막에는 점(.) 을 사용할 수 없다.
                // 그러므로 접미사의 마지막 글자가 점(.) 인 경우를 막아야 한다.
                throw "(Suffix) Last character of suffix cannot be dot(.). Suffix : (" + param["fn_suffix"] + ")";
            }
        }

        Dropzone.options[upload_div] = new Dropzone("div#" + upload_div, {
            url: param["url"],
            maxFiles: param["maxFiles"],     // 파일 개수
            maxFilesize: param["maxFilesize"], // 각각의 파일 최고 크기 (256MB)
            parallelUploads: param["maxFiles"],     // 한 번에 몇 개까지 올릴 것인지를 확인 (1이면 단일 업로드)
            uploadMultiple: param["multiple"],
            createImageThumbnails: false,
            paramName: param["uploadName"],
            filesizeBase: 1024,
            previewsContainer: "#" + upload_div,
            acceptedFiles: param["fileExt"],
            params: param["addParams"],
            init: function() {
                var dz_obj = this; // Dropzone.options.fileUploader 객체
                var idx = -1;
                var dropzoneIdx = -1;
                var uploadFileObj = [];
                var deleteFileObj = [];

                // 이미 업로드 된 파일을 표시함
                uploadFileObj = obj.data("upload_data");
                if(typeof(uploadFileObj) == 'undefined') {
                    obj.data("upload_data", []);
                    uploadFileObj = [];
                }
                // 삭제된 파일 정보를 가지고 있음
                deleteFileObj = obj.data("delete_data");
                if(typeof(deleteFileObj) == 'undefined') {
                    obj.data("delete_data", []);
                    deleteFileObj = [];
                }
                // for 문의 mf 형식 예제
                /*
                mf = {
                    "name" : "파일명"
                    "size" : "파일 사이즈" // 파일 업로드 하는 부분에 대해서는 없어도 문제 없음
                    "uuid" : "UUID" // 파일 업로드 하는 부분에 대애서는 없어도 문제 없음
                    "file_key" : file_key 컬럼값
                    "file_rel_key" : file_rel_key 컬럼값
                }
                */
                if(param["initFiles"].length > 0) {
                    for(var mf in param["initFiles"]) {
                        dz_obj.emit("addedfile", param["initFiles"][mf]);
                        // dz_obj.emit("success", param["initFiles"][mf]);
                        dz_obj.emit("complete", param["initFiles"][mf]);
                        uploadFileObj.push({"uuid" : "", "file_name" : param["initFiles"][mf]["name"], "file_key" : param["initFiles"][mf]["file_key"], "file_rel_key" : param["initFiles"][mf]["file_rel_key"]});
                    }
                    obj.data("upload_data", uploadFileObj);
                }

                this.on("maxfilesexceeded", function(file) {
                    dz_obj.removeFile(file);
                });
                this.on("success", function(file, result, progEvent) {
                	try {
                        // 이 success 함수는 2개 이상 동시에 업로드 할 경우, 파일 순서대로 수행된다.
                        // 단, dz_obj.files 에는 모두 들어가 있음
                        // 예) 업로드 순서가 B.pdf C.pdf A.pdf 인 경우
                        //     B.pdf 에 대한 업로드 성공 함수 (file 파라미터에는 B.pdf 에 대한 정보만 있음. C.pdf, A.pdf 의 상태는 "uploading" 상태이며 B.pdf 는 "success" 상태이다.)
                        //     C.pdf 에 대한 업로드 성공 함수 (file 파라미터에는 C.pdf 에 대한 정보만 있음. A.pdf 의 상태는 "uploading" 상태이며 B.pdf, C.pdf 는 "success" 상태이다.)
                        //     A.pdf 에 대한 업로드 성공 함수 (file 파라미터에는 A.pdf 에 대한 정보만 있음. 모두 "success" 상태이다.)

                        var tmpObj, tmp, successCount = 0, tmp_file_key = [], tmp_file_rel_key = [], tmp_file_name = [], tmp_disp_file_name = [], tmp_file_path = [];
                        uploadFileObj = obj.data("upload_data");

                        // 업로드 파일 객체가 없다면 생성해주기 위함
                        if(typeof(uploadFileObj) == 'undefined') {
                            uploadFileObj = [];
                        }

                        // 기존 파일 추가시 success 이벤트는 수행되나, result 값은 오지 않기 때문에 initFiles 파라미터를 이용하여 파일 추가를 해야 함
                        if(typeof(result) == 'undefined') {
                            result = {};

                            for(var mf in param["initFiles"]) {
                                tmp_file_key.push(param["initFiles"][mf]["file_key"]);
                                tmp_file_rel_key.push(param["initFiles"][mf]["file_rel_key"]);
                                tmp_file_name.push(param["initFiles"][mf]["name"]);
                                tmp_disp_file_name.push(param["initFiles"][mf]["disp_file_name"]);
                                tmp_file_path.push(param["initFiles"][mf]["file_path"]);
                            }

                            result = {
                                "initFiles" : true, // 기존 파일 추가하는 경우를 구별하기 위한 파라미터
                                "count" : 1,
                                "file_key" : tmp_file_key,
                                "file_rel_key" : tmp_file_rel_key,
                                "real_file_name" : tmp_file_name,
                                "disp_file_name" : tmp_disp_file_name,
                                "file_path" : tmp_file_path,
                                "message" : LangData.get("L00193"),
                                "status" : "success"
                            };

                            // 추가 파라미터를 넣은 다음에 기본 파라미터를 추가한다.
                            dz_obj.options.params = param["addParams"];
                            dz_obj.options.params["upload_folder"] = param["uploadFolder"];

                            if(typeof(result["initFiles"]) != 'undefined') {
                                // 기존 파일을 표시해야 하는 경우..
                                idx = uploadFileObj.length; // index 는 길이-1 이므로..

                                // 해당 index 가 없다면 (undefined) JSON 배열로 생성
                                if(typeof(dz_obj.files[idx]) == 'undefined') {
                                    dz_obj.files[idx] = {
                                        "status" : "success",
                                        "accepted" : Dropzone.ACCEPTED
                                    };
                                }

                                dz_obj.files[idx]["name"] = result["disp_file_name"][idx];
                                uploadFileObj.push({
                                    "uuid" : typeof(file["upload"]) != 'undefined' ? file["upload"]["uuid"] : file["uuid"],
                                    "file_name" : result["real_file_name"][idx],
                                    "file_key" : result["file_key"][idx],
                                    "file_rel_key" : result["file_rel_key"][idx],
                                    "disp_name" : result["disp_file_name"][idx],
                                    "file_path" : (result["file_path"][idx] ? result["file_path"][idx] : ""),
                                });
                                obj.data("upload_data", uploadFileObj);

                                // 업로드 파일 정보에 따라 html 갱신
                                tmpObj = $("#" + upload_div + " .dz-preview:eq(" + idx + ")");
                                if($("#" + upload_div + " .dz-preview:eq(" + idx + ") .dz-wrapper").length < 1) {
                                    tmp = $("#" + upload_div + " .dz-preview:eq(" + idx + ")").html();
                                    tmpObj.html("").append("<div class=\"dz-wrapper\">" + tmp + "</div>")
                                        .find(".dz-error-mark title").text(LangData.get("L00371"));
                                    if(typeof(result["initFiles"]) != 'undefined') {
                                        tmpObj.find(".dz-filename span").text(result["disp_file_name"][idx]);
                                    }
                                }
                            } else {
                                // 최초 파일 세팅하는 경우에 파일 정보가 없으면 아무것도 하지 않음
                            }
                        } else {
                            if(parseInt(result["count"], 10) < 1) {
                                notifyDanger(result["message"]);
                            } else if (param["url"].indexOf("/temp_excel") > -1) {
                                obj.data("upload_cleared", false);
                                // 모두 성공했을 때 호출하는 함수
                                param["success"].call(null, result);
                            } else {
                                // 개별 파일 업로드 성공

                                // 추가 파라미터를 넣은 다음에 기본 파라미터를 추가한다.
                                dz_obj.options.params = param["addParams"];
                                dz_obj.options.params["upload_folder"] = param["uploadFolder"];

                                // 모든 업로드 파일 중 상태가 success 인 것 중 마지막 인덱스를 찾음
                                // 그 인덱스와 컨트롤러에서 받아온 result["file_key"] 의 인덱스와 맞춰줌
                                if(typeof(result["initFiles"]) != 'undefined') {
                                    idx = 0;
                                    dropzoneIdx = 0;
                                } else {
                                    for(var i = dz_obj.files.length - 1; i >= 0; i--) {
                                        if(dz_obj.files[i].status == "success") {
                                            idx = i - (dz_obj.files.length - result["file_key"].length);
                                            dropzoneIdx = i;
                                            break;
                                        }
                                    }
                                }

                                // 해당 index 가 없다면 (undefined) JSON 배열로 생성
                                if(typeof(dz_obj.files[dropzoneIdx]) == 'undefined') {
                                    dz_obj.files[dropzoneIdx] = {
                                        "status" : "success",
                                        "accepted" : Dropzone.ACCEPTED
                                    };
                                }

                                dz_obj.files[dropzoneIdx]["name"] = result["disp_file_name"][idx];
                                uploadFileObj.push({
                                    "uuid" : typeof(file["upload"]) != 'undefined' ? file["upload"]["uuid"] : file["uuid"],
                                    "file_name" : result["real_file_name"][idx],
                                    "file_key" : result["file_key"][idx],
                                    "file_rel_key" : result["file_rel_key"][idx],
                                    "disp_name" : result["disp_file_name"][idx],
                                    "file_path" : (result["file_path"][idx] ? result["file_path"][idx] : ""),
                                });
                                obj.data("upload_data", uploadFileObj);

                                // 업로드 파일 정보에 따라 html 갱신
                                for(var i = 0; i < dz_obj.files.length; i++) {
                                    tmpObj = $("#" + upload_div + " .dz-preview:eq(" + i + ")");
                                    if($("#" + upload_div + " .dz-preview:eq(" + i + ") .dz-wrapper").length < 1) {
                                        tmp = $("#" + upload_div + " .dz-preview:eq(" + i + ")").html();
                                        tmpObj.html("").append("<div class=\"dz-wrapper\">" + tmp + "</div>")
                                            .find(".dz-error-mark title").text(LangData.get("L00371"));
                                        if(typeof(result["initFiles"]) != 'undefined') {
                                            tmpObj.find(".dz-filename span").text(result["disp_file_name"][idx]);
                                        }
                                    }

                                    if(dz_obj.files[i].status == "success") {
                                        successCount++;
                                    }
                                }

                                if(successCount == dz_obj.files.length) {
                                    obj.data("upload_cleared", false);
                                    // 모두 성공했을 때 호출하는 함수
                                    param["success"].call(null, result, dz_obj.files);
                                }
                            }
                        }

                        // dz-wrapper 클래스가 없는 경우 감싸주도록 함
                        $("#" + upload_div + " .dz-preview").each(function(idx, elem) {
                            if($(elem).find(".dz-wrapper").length < 1) {
                                var tmp = $(elem).html();
                                $(elem).html("").append("<div class=\"dz-wrapper\">" + tmp + "</div>")
                                    .find(".dz-error-mark title").text(LangData.get("L00371"));
                            }
                        });
                	} catch (e) {
                        param["error"].call(null, file, e);
                        notifyDanger(LangData.get("L00376") + " : -1" + "<br>(" + file.name + ")");
                        dz_obj.removeFile(file);
                	}

                    changeLoadingImageStatus(false);
                });
                this.on("error", function(file, errorMessage) {
                    // 오류 발생시
                    param["error"].call(null, file, errorMessage);
                    notifyDanger(errorMessage + "<br>(" + file.name + ")");
                    console.log(errorMessage);
                    dz_obj.removeFile(file);

                    changeLoadingImageStatus(false);
                });
                this.on("drop", function(ev) {
                });
                this.on("sending", function(ev) {
                    changeLoadingImageStatus(true);
                });

                for(var i = 0; i < dz_obj.files.length; i++) {
                    var tmpObj = $("#" + upload_div + " .dz-preview:eq(" + i + ")");
                    if($("#" + upload_div + " .dz-preview:eq(" + i + ") .dz-wrapper").length < 1) {
                        var tmp = $("#" + upload_div + " .dz-preview:eq(" + i + ")").html();
                        tmpObj.html("").append("<div class=\"dz-wrapper\">" + tmp + "</div>")
                            .find(".dz-error-mark title").text(LangData.get("L00371"));
                        tmpObj.find(".dz-filename span").text(result["disp_file_name"][idx]);
                    }
                }

                obj.data("upload_obj", dz_obj);
            },
            dictDefaultMessage: LangData.get("L00372") + " " + g_ServerMaxUploadFileSize, // g_ServerMaxUploadFileSize 변수는 layout 에 정의되어 있음
            dictFallbackMessage: LangData.get("L00373"),
            dictFallbackText: null,
            dictFileTooBig: LangData.get("L00374") + "\n({{filesize}} MB > {{maxFilesize}} MB).",
            dictInvalidFileType: LangData.get("L00375"),
            dictResponseError: LangData.get("L00376") + " {{statusCode}}",
            dictCancelUpload: LangData.get("L00377"),
            dictUploadCanceled: LangData.get("L00378"),
            dictCancelUploadConfirmation: LangData.get("L00379"),
            dictRemoveFile: LangData.get("L00371"),
            dictRemoveFileConfirmation: LangData.get("L00380"),
            dictMaxFilesExceeded: LangData.get("L00381") + " {{maxFiles}}",
            dictFileSizeUnits: { tb: "TB", gb: "GB", mb: "MB", kb: "KB", b: "B" }
        });

        obj.data("upload_func", {
            /**
             * 현재 업로드 되어 있는 파일 키를 배열로 리턴
             */
            getFileKey: function() {
                return this.getFileData("file_key");
            },
            /**
             * 현재 업로드 되어 있는 파일 키를 배열로 리턴 (새로 업로드 된 것만)
             */
            getNewFileKey: function() {
                return this.getNewFileData("file_key");
            },
            /**
             * 현재 업로드 되어 있는 파일 연계 키를 배열로 리턴
             */
            getFileRelKey: function() {
                return this.getFileData("file_rel_key");
            },
            /**
             * 현재 업로드 되어 있는 파일 연계 키를 배열로 리턴 (새로 업로드 된 것만)
             */
            getNewFileRelKey: function() {
                return this.getNewFileData("file_rel_key");
            },
            /**
             * upload_data 객체에서 특정한 키값을 배열로 리턴함
             *
             * @param {String} p_KeyName 키값 (uuid, file_name, file_key, file_rel_key 중 하나)
             */
            getFileData: function(p_KeyName) {
                var ret_val = [];
                if(typeof(obj.data("upload_data")) != 'undefined') {
                    if(obj.data("upload_data").length > 0) {
                        var upload_data = obj.data("upload_data");
                        for(var i = 0; i < upload_data.length; i++) {
                            ret_val.push(upload_data[i][p_KeyName]);
                        }
                        return ret_val;
                    } else {
                        return ret_val;
                    }
                } else {
                    return ret_val;
                }
            },
            /**
             * 삭제된 파일의 파일 연계 키를 가지고 옴
             */
            getDeleteFileRelKey: function() {
                var deletedObj = obj.data("delete_data"); // 없으면 빈 배열로 리턴함
                var ret_obj = [];

                if(typeof(deletedObj) != 'undefined') {
                    for(var i = 0; i < deletedObj.length; i++) {
                        ret_obj.push(deletedObj[i]["file_rel_key"]);
                    }
                }

                return ret_obj;
            },
            /**
             * upload_data 객체에서 특정한 키값을 배열로 리턴함
             * 단, 새로 업로드 된 값만 배열로 리턴함
             */
            getNewFileData: function(p_KeyName) {
                var ret_val = [];
                if(typeof(obj.data("upload_data")) != 'undefined') {
                    if(obj.data("upload_data").length > 0) {
                        var upload_data = obj.data("upload_data");
                        for(var i = 0; i < upload_data.length; i++) {
                            if(upload_data[i]["uuid"] != "") {      // 기존 업로드 파일은 uuid 값을 세팅하지 않음 (param["initFiles"] 참고)
                                ret_val.push(upload_data[i][p_KeyName]);
                            }
                        }
                        return ret_val;
                    } else {
                        return ret_val;
                    }
                } else {
                    return ret_val;
                }
            },
            /**
             * 임시 파일 제거 및 화면 클리어
             * @param {Boolean} p_Ask 업로드 된 파일이 있다면 클리어 전에 한 번 물어볼지 말지를 결정함. 파일이 없으면 물어보지 않음. true 는 물어보도록 하며, false 는 물어보지 않고 처리함. (기본값은 true)
             * @param {Boolean} p_Message 메시지 표시 여부 (기본 true)
             */
            clearAllData: function(p_Ask, p_Message) {

                p_Ask = typeof(p_Ask) != 'boolean' ? true : p_Ask;
                p_Message = typeof(p_Message) != 'boolean' ? true : p_Message;

                if(p_Ask && !obj.data("upload_cleared")) {
                    if(!confirm(LangData.get("L00382"))) {
                        return false;
                    }
                }

                obj.data("upload_cleared", true);

                var uploadFileObj = [];
                var exitCheck = false;
                uploadFileObj = obj.data("upload_data");
                uploadFileObj = uploadFileObj || [];

                if(Dropzone.options[upload_div].files.length < 1 || uploadFileObj.length < 1) {
                    if(p_Message) {
                        notifyDanger(LangData.get("L00393"));
                    } else {

                        // html 제거
                        obj.find(".dz-preview").remove();
                        // 파일 업로드 된 것 모두 삭제 및 업로드 중인 것도 취소
                        Dropzone.options[upload_div].removeAllFiles(true);
                        // 내부 데이터 초기화
                        obj.data("upload_data", []);
                        // 삭제된 파일 정보도 삭제
                        obj.data("delete_data", []);

                        for(var mf in param["initFiles"]) {
                            // Dropzone.options[upload_div].emit("init");
                            Dropzone.options[upload_div].emit("addedfile", param["initFiles"][mf]);
                            Dropzone.options[upload_div].emit("success", param["initFiles"][mf]);
                            // Dropzone.options[upload_div].files.push(param["initFiles"][mf]);
                            // uploadFileObj.push({"uuid" : "", "file_name" : param["initFiles"][mf]["name"], "file_key" : param["initFiles"][mf]["file_key"], "file_rel_key" : param["initFiles"][mf]["file_rel_key"], "orig_file_name" : param["initFiles"][mf]["orig_name"]});
                        }
                    }
                    return;
                }

                // 전체 파일 삭제
                // 업로드 파일 정보 가져온 후 세팅한다.
                param["deleteParams"]["file_rel_key[]"] = [];
                param["deleteParams"]["_token"] = $("meta[name='csrf-token']").attr("content");
                param["deleteParams"]["file_key[]"] = [];

                for(var i = 0; i < uploadFileObj.length; i++) {
                    param["deleteParams"]["file_key[]"].push(uploadFileObj[i]["file_key"]);
                    param["deleteParams"]["file_rel_key[]"].push(uploadFileObj[i]["file_rel_key"]);
                }

                // 가지고 올 때 사용했던 변수는 다시 초기화한다.
                uploadFileObj = [];

                // html 제거
                obj.find(".dz-preview").remove();
                // 파일 업로드 된 것 모두 삭제 및 업로드 중인 것도 취소
                Dropzone.options[upload_div].removeAllFiles(true);
                // 내부 데이터 초기화
                obj.data("upload_data", []);
                // 삭제된 파일 정보도 삭제
                obj.data("delete_data", []);

                // handle 함수를 정의하지 않고 넣기 위해 $.ajax 그대로 사용
                $.ajax({
                    method: "POST",
                    url: param["deleteAllUrl"],
                    data: param["deleteParams"],
                    dataType: "json",
                    success: function(data, textStatus, jqXHR) {
                        for(var mf in param["initFiles"]) {
                            Dropzone.options[upload_div].emit("addedfile", param["initFiles"][mf]);
                            Dropzone.options[upload_div].emit("success", param["initFiles"][mf]);
                            // Dropzone.options[upload_div].files.push(param["initFiles"][mf]);
                            // uploadFileObj.push({"uuid" : "", "file_name" : param["initFiles"][mf]["name"], "file_key" : param["initFiles"][mf]["file_key"], "file_rel_key" : param["initFiles"][mf]["file_rel_key"], "orig_file_name" : param["initFiles"][mf]["orig_name"]});
                        }
                        // 전체 삭제 성공 이벤트 실행
                        param["deleteAllSuccess"].call(null, data, textStatus, jqXHR);
                    },
                    error: function(data, textStatus, errorThrown) {
                        // 전체 삭제 실패 이벤트 실행
                        param["deleteAllError"].call(null, data, textStatus, errorThrown);
                    }
                });
            },
            /**
             * 삭제된 파일 데이터에 대한 내용을 삭제
             */
            clearDeleteData: function() {
                obj.data("delete_data", []);
            },
            /**
             * 최초 표시할 파일에 대한 정보를 갱신한다.
             * clearAllData() 함수 호출시 적용된다.
             *
             * @param {JSON} p_FileList 파일 정보 (배열과 JSON 배열로 이루어진 object)
             */
            setInitFiles: function(p_FileList) {
                param["initFiles"] = p_FileList;
            },
            setTempUploadFolder: function(p_FolderName) {
                param["uploadFolder"] = p_FolderName;
            },
            setRealUploadFolder: function(p_FolderName) {
                param["realUploadFolder"] = p_FolderName;
            },
            /**
             * 서버에 저장되는 파일명의 앞에 붙여줄 접두사를 세팅하는 함수
             *
             * @param {String} p_String 바꿀 문자열
             */
            setPrefix: function(p_String) {

                if(deny_file_name.test(param["fn_prefix"])) {
                    // 사용할 수 없는 문자열입니다.
                    throw "(Prefix) The string cannot be used in file name. String : (" + element + ")";
                }

                param["fn_prefix"] = p_String;
                param["addParams"]["fn_prefix"] = p_String;
            },
            /**
             * 서버에 저장되는 파일명의 뒤에 붙여줄 접미사를 세팅하는 함수
             *
             * @param {String} p_String 바꿀 문자열
             */
            setSuffix: function(p_String) {

                if(deny_file_name.test(param["fn_suffix"])) {
                    throw "(Suffix) The string cannot be used in file name. String : (" + element + ")";
                } else if(param["fn_suffix"].lastIndexOf(".") == param["fn_suffix"].length - 1 && param["fn_suffix"].length > 0) {
                    // 파일 이름의 마지막에는 점(.) 을 사용할 수 없다.
                    // 그러므로 접미사의 마지막 글자가 점(.) 인 경우를 막아야 한다.
                    throw "(Suffix) Last character of suffix cannot be dot(.). Suffix : (" + param["fn_suffix"] + ")";
                }

                param["fn_suffix"] = p_String;
                param["addParams"]["fn_suffix"] = p_String;
            },
            /**
             * 업로드 모듈 사용 여부. 기본값은 true(사용).
             *
             * @param {Boolean} p_Enabled 업로드 모듈 사용 여부(true 사용)
             */
            setEnabled: function(p_Enabled) {

                p_Enabled = typeof(p_Enabled) != 'boolean' ? true : p_Enabled;

                if(p_Enabled) {
                    Dropzone.options[upload_div].enable();
                } else {
                    Dropzone.options[upload_div].disable();
                }
            },
            /**
             * 삭제시 추가로 필요한 파라미터 설정
             *
             * @param {JSON} p_Param 삭제시 필요한 파라미터
             */
            setDeleteParams: function(p_Param) {
                param["deleteParams"] = p_Param;
            }
        });

        // 파일 이름 클릭시 새 창으로 파일 보여주기
        $("#" + upload_div).on("click", ".dz-preview.dz-file-preview.dz-success span[data-dz-name]", function(ev) {
            ev.stopPropagation();
            ev.preventDefault();
            var obj = $(this);
            var file_info = $("#" + upload_div).data("upload_data");

            if(file_info.length > 0) {
                if(file_info[obj.parentsUntil("div.dz-preview").parent().index()]["uuid"] == "") {
                    window.open(file_info[obj.parentsUntil("div.dz-preview").parent().index()]["file_path"] + file_info[obj.parentsUntil("div.dz-preview").parent().index()]["file_name"]);
                } else {
                    window.open("/uploads/" + param["uploadFolder"] + "/" + file_info[obj.parentsUntil("div.dz-preview").parent().index()]["file_name"]);
                }
            }
        });

        // 한 개 파일 삭제
        $("#" + upload_div + "").on("click", ".dz-preview .dz-error-mark svg", function(ev) {
            ev.stopPropagation();
            ev.preventDefault();
            var _this = $(this);
            var uploadFileObj = [];
            var deleteFileObj = [];
            // 실제 파일 삭제인지, 임시 파일 삭제인지 구분 (실제파일일 경우에는 true)
            var real_data_check = false;
            if(confirm(LangData.get("L00380"))) {
                var file_idx = _this.parent().parent().parent().not("p").index();
                var del_url = "";
                // 서버에서 해당 파일 삭제
                // 업로드 파일 정보 가져온 후 세팅한다.
                uploadFileObj = obj.data("upload_data");
                if(uploadFileObj[file_idx]["uuid"] == "") {
                    delete param["deleteParams"]["file_rel_key"];
                    delete param["deleteParams"]["file_key"];
                    param["deleteParams"]["file_rel_key[]"] = [uploadFileObj[file_idx]["file_rel_key"]];    // 배열로 넘기기 위해 대괄호로 한 번 더 감싸도록 함
                    param["deleteParams"]["file_key[]"] = [uploadFileObj[file_idx]["file_key"]];            // 배열로 넘기기 위해 대괄호로 한 번 더 감싸도록 함
                    param["deleteParams"]["upload_folder"] = param["realUploadFolder"];
                    param["deleteParams"]["query_id"] = param["query_id"];
                    param["deleteParams"]["controller"] = param["controller"];
                    del_url = param["deleteRealUrl"];
                    real_data_check = true;
                } else {
                    param["deleteParams"]["upload_folder"] = param["uploadFolder"];
                    param["deleteParams"]["file_rel_key"] = uploadFileObj[file_idx]["file_rel_key"];
                    param["deleteParams"]["file_key"] = uploadFileObj[file_idx]["file_key"];
                    del_url = param["deleteUrl"];
                }

                param["deleteParams"]["_token"] = $("meta[name='csrf-token']").attr("content");
                param["deleteParams"]["fn_prefix"] = param["fn_prefix"];
                param["deleteParams"]["fn_suffix"] = param["fn_suffix"];

                // 가지고 올 때 사용했던 변수는 다시 초기화한다.
                uploadFileObj = [];

                // handle 함수를 정의하지 않고 넣기 위해 $.ajax 그대로 사용
                $.ajax({
                    method: "POST",
                    url: del_url,
                    data: param["deleteParams"],
                    dataType: "json",
                    success: function(data, textStatus, jqXHR) {
                        if(data["count"] > 0) {
                            var dz_obj =  obj.data("upload_obj");
                            var upload_data = $("#" + upload_div).data("upload_data");

                            dz_obj.removeFile(dz_obj.files[file_idx]);

                            if(real_data_check) {
                                // 실제 파일일 경우 삭제할 파일의 정보를 넣어준다.
                                deleteFileObj = obj.data("delete_data");
                                deleteFileObj.push(upload_data[file_idx]);
                                obj.data("delete_data", deleteFileObj);

                                // 직접 해당 인덱스의 html 을 안보이게 처리하도록 한다.
                                $("#" + upload_div + " .dz-preview:eq(" + file_idx + ")").remove();
                            }

                            // 화면에서 해당 파일 삭제
                            uploadFileObj = obj.data("upload_data");
                            uploadFileObj.splice(file_idx, 1);
                            obj.data("upload_data", uploadFileObj);
                            uploadFileObj = [];

                            if(dz_obj.files.length < 1) {
                                // 파일 업로드 된 것 모두 삭제 및 업로드 중인 것도 취소
                                Dropzone.options[upload_div].removeAllFiles(true);
                                // 내부 데이터 초기화
                                obj.data("upload_data", []);
                            }
                            // notifySuccess(data["message"]);
                            param["deleteSuccess"].call(null, data, textStatus, jqXHR);

                            obj.data("upload_obj", dz_obj);
                        } else {
                            // notifyDanger(data["message"]);
                            param["deleteError"].call(null, data, textStatus, jqXHR);
                        }
                    },
                    error: function(data, textStatus, errorThrown) {
                        param["deleteError"].call(null, data, textStatus, errorThrown);
                    }
                });
            }
        });

        $(window).on("beforeunload", function() {

            if(!obj.data("upload_cleared")) {
                if(!confirm(LangData.get("L00382"))) {
                    return false;
                }
            }

            obj.data("upload_func").clearAllData(true, false);
        });

        return Dropzone.options[upload_div];
    };

    // 여러 개의 업로드 객체에서 업로드 된 모든 파일 키를 하나의 배열로 저장한다.
    $.fn.getAllFileKey = function() {

        var file_key = [];
        var upload_obj = null;
        var obj = $(this);
        var tmp_key = [];

        for(var i = 0; i < obj.length; i++) {
            tmp_key = $(obj[i]).data("upload_func").getFileKey();
            tmp_key.forEach(function(elem) {
                file_key.push(elem);
            });
        }

        return file_key;
    };

    // 여러 개의 업로드 객체에서 업로드 된 모든 파일 키를 하나의 배열로 저장한다. (새로 업로드 한 데이터만)
    $.fn.getAllNewFileKey = function() {

        var file_key = [];
        var upload_obj = null;
        var obj = $(this);
        var tmp_key = [];

        for(var i = 0; i < obj.length; i++) {
            tmp_key = $(obj[i]).data("upload_func").getNewFileKey();
            tmp_key.forEach(function(elem) {
                file_key.push(elem);
            });
        }

        return file_key;
    };

    // 여러 개의 업로드 객체에서 업로드 된 모든 파일 연계 키를 하나의 배열로 저장한다.
    $.fn.getAllFileRelKey = function() {

        var file_rel_key = [];
        var upload_obj = null;
        var obj = $(this);
        var tmp_key = [];

        for(var i = 0; i < obj.length; i++) {
            tmp_key = $(obj[i]).data("upload_func").getFileRelKey();
            tmp_key.forEach(function(elem) {
                file_rel_key.push(elem);
            });
        }

        return file_rel_key;
    };

    // 여러 개의 업로드 객체에서 업로드 된 모든 파일 연계 키를 하나의 배열로 저장한다. (새로 업로드 한 데이터만)
    $.fn.getAllNewFileRelKey = function() {

        var file_rel_key = [];
        var obj = $(this);
        var tmp_key = [];

        for(var i = 0; i < obj.length; i++) {
            tmp_key = $(obj[i]).data("upload_func").getNewFileRelKey();
            tmp_key.forEach(function(elem) {
                file_rel_key.push(elem);
            });
        }

        return file_rel_key;
    };

    // 여러 개의 업로드 객체에서 삭제된 모든 파일 연계 키를 하나의 배열로 저장한다.
    $.fn.getAllDelFileRelKey = function() {
        var file_rel_key = [];
        var obj = $(this);
        var tmp_key = [];

        for(var i = 0; i < obj.length; i++) {
            tmp_key = $(obj[i]).data("upload_func").getDeleteFileRelKey();
            tmp_key.forEach(function(elem) {
                file_rel_key.push(elem);
            });
        }

        return file_rel_key;
    };

});
