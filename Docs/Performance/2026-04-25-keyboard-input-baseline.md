# Performance Baseline - Keyboard Input Modifiers

## Run Metadata

| Field | Value |
| --- | --- |
| Repository | `SwiftTUI` |
| Date | `2026-04-25` |
| Command | `swift test --filter 'HStackPerformanceTests|VStackPerformanceTests|PerformanceBenchmarkTests'` |
| Platform | `arm64e-apple-macos14.0` |
| Result | `33 benchmark tests passed` |

## Suite Summary

| Suite | Tests | Result | Suite Duration |
| --- | ---: | --- | ---: |
| `HStackPerformanceTests` | 11 | Pass | `2.862 s` |
| `PerformanceBenchmarkTests` | 11 | Pass | `0.495 s` |
| `VStackPerformanceTests` | 11 | Pass | `2.860 s` |

## HStack Benchmarks

| Test | Avg Wall Time (s) | RSD % |
| --- | ---: | ---: |
| `testPerformance_1024Fixed` | `0.001` | `8.568` |
| `testPerformance_1024Mixed` | `0.001` | `8.111` |
| `testPerformance_128Fixed` | `0.000` | `16.776` |
| `testPerformance_16Fixed` | `0.000` | `73.023` |
| `testPerformance_16Mixed` | `0.000` | `66.664` |
| `testPerformance_256Fixed` | `0.001` | `94.229` |
| `testPerformance_256Mixed` | `0.000` | `16.452` |
| `testPerformance_4Fixed` | `0.000` | `107.416` |
| `testPerformance_512Fixed` | `0.001` | `47.393` |
| `testPerformance_64Fixed` | `0.000` | `27.474` |
| `testPerformance_64Mixed` | `0.000` | `37.543` |

## VStack Benchmarks

| Test | Avg Wall Time (s) | RSD % |
| --- | ---: | ---: |
| `testPerformance_1024Fixed` | `0.001` | `37.143` |
| `testPerformance_1024Mixed` | `0.001` | `37.845` |
| `testPerformance_128Fixed` | `0.000` | `42.601` |
| `testPerformance_16Fixed` | `0.000` | `69.624` |
| `testPerformance_16Mixed` | `0.000` | `46.091` |
| `testPerformance_256Fixed` | `0.000` | `57.568` |
| `testPerformance_256Mixed` | `0.000` | `19.814` |
| `testPerformance_4Fixed` | `0.000` | `85.754` |
| `testPerformance_512Fixed` | `0.001` | `52.424` |
| `testPerformance_64Fixed` | `0.000` | `37.032` |
| `testPerformance_64Mixed` | `0.000` | `25.523` |

## AttributeGraph Clock Benchmarks

| Test | Avg Clock Time (s) | Clock RSD % |
| --- | ---: | ---: |
| `testBinaryTree1024LeavesInitialEvaluation` | `0.000` | `13.487` |
| `testBinaryTree1024LeavesReEvaluationAfterSourceChange` | `0.009` | `9.536` |
| `testDeepChain1000InitialEvaluation` | `0.000` | `5.547` |
| `testDeepChain1000NoOpWrite` | `0.000` | `40.381` |
| `testDeepChain1000ReEvaluationAfterSourceChange` | `0.003` | `4.698` |
| `testMultiDiamond64x8InitialEvaluation` | `0.000` | `25.352` |
| `testMultiDiamond64x8ReEvaluationAfterSourceChange` | `0.003` | `8.399` |
| `testPendingCut1000DownstreamNodesSkippedAfterNoOpClamp` | `0.001` | `4.139` |
| `testSharedNodeEvaluatedOnceAcross500Dependents` | `0.002` | `7.602` |
| `testWideFanOut5000InitialEvaluation` | `0.001` | `4.375` |
| `testWideFanOut5000ReEvaluationAfterSourceChange` | `0.012` | `5.048` |

## AttributeGraph Memory Benchmarks

| Test | Peak Physical Avg (kB) | Peak Physical RSD % | Physical Avg (kB) | Physical RSD % |
| --- | ---: | ---: | ---: | ---: |
| `testBinaryTree1024LeavesInitialEvaluation` | `10386.586` | `0.402` | `1.638` | `300.000` |
| `testBinaryTree1024LeavesReEvaluationAfterSourceChange` | `11920.128` | `0.206` | `4.915` | `300.000` |
| `testDeepChain1000InitialEvaluation` | `12387.072` | `0.000` | `0.000` | `0.000` |
| `testDeepChain1000NoOpWrite` | `12908.083` | `0.051` | `0.000` | `0.000` |
| `testDeepChain1000ReEvaluationAfterSourceChange` | `13443.840` | `0.061` | `1.638` | `300.000` |
| `testMultiDiamond64x8InitialEvaluation` | `13730.560` | `0.000` | `0.000` | `0.000` |
| `testMultiDiamond64x8ReEvaluationAfterSourceChange` | `14035.302` | `0.057` | `0.000` | `0.000` |
| `testPendingCut1000DownstreamNodesSkippedAfterNoOpClamp` | `17990.400` | `0.000` | `0.000` | `0.000` |
| `testSharedNodeEvaluatedOnceAcross500Dependents` | `18318.080` | `0.000` | `0.000` | `0.000` |
| `testWideFanOut5000InitialEvaluation` | `20515.174` | `0.024` | `1.638` | `300.000` |
| `testWideFanOut5000ReEvaluationAfterSourceChange` | `22767.974` | `0.048` | `3.277` | `200.000` |

## Comparison Notes

| Topic | Note |
| --- | --- |
| Comparison target | `Docs/Performance/Performances.md` from `2026-04-10` |
| Result | `33/33 benchmark tests passed` |
| AttributeGraph clock | No actionable regression; re-evaluation benchmarks are equal or faster than the previous rounded averages. |
| Layout wall-clock | Sub-millisecond layout tests remain noisy. `HStack testPerformance_256Fixed` rounded to `0.001 s` with high RSD, indicating an outlier rather than stable regression. |
| Change scope | Keyboard input modifiers do not alter layout or AttributeGraph hot paths. |
