package kr.yeongju.its.ad.common.dto;

import kr.yeongju.its.ad.common.dto.CommonMap;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor(staticName = "of")
public class ResultInfo {

    final private String message;
    final private int count;
    final private CommonMap data;
}
