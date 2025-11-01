package kr.yeongju.its.ad.common.dto;

import kr.yeongju.its.ad.common.dto.CommonMap;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor(staticName = "of")
public class GridResultInfo {

    final private CommonMap data;
}
