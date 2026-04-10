# Performance Tests

This file records the current checked-in benchmark baseline after the optional/conditional/layout fix.

Future changes should:

1. Re-run the same benchmark command.
2. Compare the new numbers against this file, or against a newer baseline file if one exists.
3. Call out any regression before considering the change complete.

## Run Metadata

| Field | Value |
| --- | --- |
| Repository | `SwiftTUI` |
| Date | `2026-04-10` |
| Command | `swift test --filter 'HStackPerformanceTests|VStackPerformanceTests|PerformanceBenchmarkTests'` |
| Platform | `arm64e-apple-macos14.0` |
| Result | `33 benchmark tests passed` |

## Suite Summary

| Suite | Tests | Result | Suite Duration |
| --- | ---: | --- | ---: |
| `HStackPerformanceTests` | 11 | Pass | `2.981 s` |
| `PerformanceBenchmarkTests` | 11 | Pass | `0.529 s` |
| `VStackPerformanceTests` | 11 | Pass | `2.833 s` |

## HStack Benchmarks

Note: XCTest rounds wall-clock averages to three decimals in its summary line. The `Values` column preserves the exact per-iteration samples that were emitted during the run.

| Test | Avg Wall Time (s) | RSD % | Values (s) |
| --- | ---: | ---: | --- |
| `testPerformance_1024Fixed` | `0.001` | `26.623` | `[0.001172, 0.000685, 0.000593, 0.000588, 0.000607, 0.000576, 0.000607, 0.000585, 0.000569, 0.000578]` |
| `testPerformance_1024Mixed` | `0.001` | `129.309` | `[0.005165, 0.000646, 0.000590, 0.000598, 0.000586, 0.000582, 0.000582, 0.000666, 0.000601, 0.000572]` |
| `testPerformance_128Fixed` | `0.000` | `18.062` | `[0.000123, 0.000077, 0.000075, 0.000075, 0.000074, 0.000074, 0.000074, 0.000076, 0.000074, 0.000077]` |
| `testPerformance_16Fixed` | `0.000` | `138.306` | `[0.000266, 0.000088, 0.000060, 0.000902, 0.000049, 0.000209, 0.000080, 0.000044, 0.000039, 0.000078]` |
| `testPerformance_16Mixed` | `0.000` | `80.582` | `[0.000067, 0.000016, 0.000015, 0.000014, 0.000014, 0.000014, 0.000014, 0.000014, 0.000014, 0.000014]` |
| `testPerformance_256Fixed` | `0.000` | `18.107` | `[0.000214, 0.000165, 0.000151, 0.000224, 0.000151, 0.000143, 0.000145, 0.000146, 0.000141, 0.000141]` |
| `testPerformance_256Mixed` | `0.000` | `38.113` | `[0.000618, 0.000425, 0.000417, 0.000415, 0.000419, 0.000413, 0.000427, 0.000189, 0.000160, 0.000167]` |
| `testPerformance_4Fixed` | `0.000` | `255.547` | `[0.000130, 0.001256, 0.000022, 0.000008, 0.000007, 0.000007, 0.000006, 0.000006, 0.000006, 0.000006]` |
| `testPerformance_512Fixed` | `0.001` | `44.699` | `[0.001128, 0.000994, 0.000845, 0.000806, 0.000710, 0.000514, 0.000430, 0.000331, 0.000323, 0.000296]` |
| `testPerformance_64Fixed` | `0.000` | `36.711` | `[0.000266, 0.000140, 0.000154, 0.000138, 0.000145, 0.000138, 0.000369, 0.000191, 0.000174, 0.000241]` |
| `testPerformance_64Mixed` | `0.000` | `183.598` | `[0.000394, 0.001446, 0.000061, 0.000043, 0.000043, 0.000068, 0.000060, 0.000043, 0.000043, 0.000079]` |

## VStack Benchmarks

Note: XCTest rounds wall-clock averages to three decimals in its summary line. The `Values` column preserves the exact per-iteration samples that were emitted during the run.

| Test | Avg Wall Time (s) | RSD % | Values (s) |
| --- | ---: | ---: | --- |
| `testPerformance_1024Fixed` | `0.001` | `19.900` | `[0.000685, 0.000583, 0.000577, 0.000585, 0.000575, 0.000599, 0.000579, 0.000783, 0.000935, 0.000906]` |
| `testPerformance_1024Mixed` | `0.001` | `32.341` | `[0.000998, 0.001026, 0.001741, 0.001730, 0.001223, 0.000920, 0.000919, 0.000916, 0.000819, 0.000621]` |
| `testPerformance_128Fixed` | `0.000` | `22.058` | `[0.000133, 0.000097, 0.000078, 0.000074, 0.000073, 0.000073, 0.000074, 0.000074, 0.000074, 0.000076]` |
| `testPerformance_16Fixed` | `0.000` | `71.027` | `[0.000056, 0.000015, 0.000014, 0.000014, 0.000013, 0.000013, 0.000013, 0.000013, 0.000013, 0.000013]` |
| `testPerformance_16Mixed` | `0.000` | `107.619` | `[0.000120, 0.000032, 0.000016, 0.000014, 0.000014, 0.000013, 0.000013, 0.000014, 0.000029, 0.000024]` |
| `testPerformance_256Fixed` | `0.000` | `9.141` | `[0.000194, 0.000161, 0.000148, 0.000147, 0.000145, 0.000167, 0.000153, 0.000159, 0.000147, 0.000145]` |
| `testPerformance_256Mixed` | `0.000` | `98.499` | `[0.000900, 0.000181, 0.000152, 0.000149, 0.000151, 0.000148, 0.000150, 0.000148, 0.000149, 0.000148]` |
| `testPerformance_4Fixed` | `0.000` | `133.439` | `[0.000059, 0.000009, 0.000007, 0.000007, 0.000006, 0.000006, 0.000006, 0.000006, 0.000006, 0.000006]` |
| `testPerformance_512Fixed` | `0.000` | `11.967` | `[0.000356, 0.000300, 0.000315, 0.000354, 0.000439, 0.000329, 0.000359, 0.000323, 0.000303, 0.000298]` |
| `testPerformance_64Fixed` | `0.000` | `44.935` | `[0.000120, 0.000066, 0.000065, 0.000043, 0.000042, 0.000040, 0.000040, 0.000041, 0.000041, 0.000041]` |
| `testPerformance_64Mixed` | `0.000` | `34.575` | `[0.000092, 0.000044, 0.000042, 0.000042, 0.000042, 0.000043, 0.000086, 0.000062, 0.000042, 0.000042]` |

## AttributeGraph Clock Benchmarks

| Test | Avg Clock Time (s) | Clock RSD % | Values (s) |
| --- | ---: | ---: | --- |
| `testBinaryTree1024LeavesInitialEvaluation` | `0.000` | `58.909` | `[0.000005, 0.000004, 0.000002, 0.000002, 0.000003, 0.000003, 0.000003, 0.000002, 0.000003, 0.000009]` |
| `testBinaryTree1024LeavesReEvaluationAfterSourceChange` | `0.010` | `4.734` | `[0.010813, 0.010094, 0.010546, 0.010575, 0.010104, 0.009774, 0.010192, 0.009458, 0.009228, 0.009850]` |
| `testDeepChain1000InitialEvaluation` | `0.000` | `12.816` | `[0.000304, 0.000237, 0.000220, 0.000219, 0.000251, 0.000207, 0.000207, 0.000208, 0.000210, 0.000209]` |
| `testDeepChain1000NoOpWrite` | `0.000` | `23.708` | `[0.000003, 0.000003, 0.000004, 0.000003, 0.000003, 0.000002, 0.000003, 0.000002, 0.000002, 0.000002]` |
| `testDeepChain1000ReEvaluationAfterSourceChange` | `0.004` | `9.484` | `[0.004456, 0.003540, 0.003305, 0.003442, 0.003495, 0.003320, 0.003409, 0.003225, 0.003331, 0.003585]` |
| `testMultiDiamond64x8InitialEvaluation` | `0.000` | `40.053` | `[0.000008, 0.000003, 0.000004, 0.000003, 0.000004, 0.000004, 0.000003, 0.000003, 0.000003, 0.000002]` |
| `testMultiDiamond64x8ReEvaluationAfterSourceChange` | `0.003` | `5.518` | `[0.002839, 0.002904, 0.002623, 0.002956, 0.002687, 0.003066, 0.003077, 0.002881, 0.002631, 0.002957]` |
| `testPendingCut1000DownstreamNodesSkippedAfterNoOpClamp` | `0.002` | `4.106` | `[0.001677, 0.001710, 0.001733, 0.001617, 0.001849, 0.001753, 0.001745, 0.001645, 0.001840, 0.001716]` |
| `testSharedNodeEvaluatedOnceAcross500Dependents` | `0.003` | `4.115` | `[0.002724, 0.002659, 0.002811, 0.002517, 0.002802, 0.002840, 0.002691, 0.002761, 0.002813, 0.002521]` |
| `testWideFanOut5000InitialEvaluation` | `0.002` | `4.287` | `[0.001633, 0.001732, 0.001858, 0.001698, 0.001695, 0.001766, 0.001639, 0.001602, 0.001741, 0.001777]` |
| `testWideFanOut5000ReEvaluationAfterSourceChange` | `0.013` | `2.964` | `[0.013276, 0.012509, 0.012572, 0.012514, 0.013351, 0.013216, 0.012735, 0.012728, 0.013516, 0.013408]` |

## AttributeGraph Memory Benchmarks

| Test | Peak Physical Avg (kB) | Peak Physical RSD % | Physical Avg (kB) | Physical RSD % |
| --- | ---: | ---: | ---: | ---: |
| `testBinaryTree1024LeavesInitialEvaluation` | `28764.494` | `0.175` | `0.000` | `0.000` |
| `testBinaryTree1024LeavesReEvaluationAfterSourceChange` | `29944.142` | `0.044` | `0.000` | `0.000` |
| `testDeepChain1000InitialEvaluation` | `30474.984` | `0.000` | `0.000` | `0.000` |
| `testDeepChain1000NoOpWrite` | `30969.781` | `0.021` | `1.638` | `300.000` |
| `testDeepChain1000ReEvaluationAfterSourceChange` | `31484.238` | `0.025` | `1.638` | `300.000` |
| `testMultiDiamond64x8InitialEvaluation` | `31784.066` | `0.015` | `1.638` | `300.000` |
| `testMultiDiamond64x8ReEvaluationAfterSourceChange` | `32075.701` | `0.046` | `3.277` | `200.000` |
| `testPendingCut1000DownstreamNodesSkippedAfterNoOpClamp` | `36766.440` | `0.000` | `0.000` | `0.000` |
| `testSharedNodeEvaluatedOnceAcross500Dependents` | `37107.227` | `0.018` | `1.638` | `300.000` |
| `testWideFanOut5000InitialEvaluation` | `39110.990` | `0.013` | `0.000` | `0.000` |
| `testWideFanOut5000ReEvaluationAfterSourceChange` | `41286.786` | `0.012` | `1.638` | `300.000` |

## Comparison Notes

| Topic | Note |
| --- | --- |
| First checked-in baseline | `Yes` |
| Future comparison target | `Compare against this file until a newer baseline file is added under Docs/Performance` |
| High-variance suites | `Small wall-clock benchmarks can show warm-up outliers. Compare the average, the RSD, and the sample list together.` |
