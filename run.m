%% TAXI - deterministic
fprintf('Running experiments in the TAXI domain (deterministic)\n');
tic; Vvi = TaxiRunner.vi(true); tvi = toc;
tic; Vpvi = TaxiRunner.plainVi(true); tpvi = toc;
assert(sum(abs(Vvi - Vpvi)) < 0.05);
tic; Vo = TaxiRunner.options(true); to = toc;
assert(sum(abs(Vvi - Vo)) < 0.05);
tic; Va = TaxiRunner.aggregation(true); ta = toc;
assert(sum(abs(Vvi - Va)) < 0.05);
tic; Voa = TaxiRunner.optionsAggregation(true); toa = toc;
assert(sum(abs(Vvi - Voa)) < 0.05);
tic; Voap = TaxiRunner.optionsAggregationPlain(true); toap = toc;
assert(sum(abs(Vvi - Voap)) < 0.05);
tic; TaxiRunner.aggregationApproximate(true); taa = toc;
tic; TaxiRunner.aggregationApproximatePlain(true); taap = toc;
fprintf('************************************************************\n');
fprintf('Summary of results in the TAXI domain (deterministic).\n');
fprintf('Model value iteration: %.2f seconds.\n', tvi);
fprintf('Plain value iteration: %.2f seconds.\n', tpvi);
fprintf('Options: %.2f seconds.\n', to);
fprintf('Aggregation: %.2f seconds.\n', ta);
fprintf('Options and aggregation (model VI): %.2f seconds.\n', toa);
fprintf('Options and aggregation (plain VI): %.2f seconds.\n', toap);
fprintf('Approx. sol. with aggregation (model VI): %.2f seconds.\n', taa);
fprintf('Approx. sol. with aggregation (plain VI): %.2f seconds.\n', taap);
fprintf('************************************************************\n');


%% TAXI - non-deterministic
fprintf('Running experiments in the TAXI domain (non-deterministic)\n');
tic; Vvi = TaxiRunner.vi(false); tvi = toc;
tic; Vpvi = TaxiRunner.plainVi(false); tpvi = toc;
assert(sum(abs(Vvi - Vpvi)) < 0.05);
tic; Vo = TaxiRunner.options(false); to = toc;
assert(sum(abs(Vvi - Vo)) < 0.05);
tic; Va = TaxiRunner.aggregation(false); ta = toc;
assert(sum(abs(Vvi - Va)) < 0.05);
tic; Voa = TaxiRunner.optionsAggregation(false); toa = toc;
assert(sum(abs(Vvi - Voa)) < 0.05);
tic; Voap = TaxiRunner.optionsAggregationPlain(false); toap = toc;
assert(sum(abs(Vvi - Voap)) < 0.05);
tic; TaxiRunner.aggregationApproximate(false); taa = toc;
tic; TaxiRunner.aggregationApproximatePlain(false); taap = toc;
fprintf('************************************************************\n');
fprintf('Summary of results in the TAXI domain (non-deterministic).\n');
fprintf('Model value iteration: %.2f seconds.\n', tvi);
fprintf('Plain value iteration: %.2f seconds.\n', tpvi);
fprintf('Options: %.2f seconds.\n', to);
fprintf('Aggregation: %.2f seconds.\n', ta);
fprintf('Options and aggregation (model VI): %.2f seconds.\n', toa);
fprintf('Options and aggregation (plain VI): %.2f seconds.\n', toap);
fprintf('Approx. sol. with aggregation (model VI): %.2f seconds.\n', taa);
fprintf('Approx. sol. with aggregation (plain VI): %.2f seconds.\n', taap);
fprintf('************************************************************\n');


%% Hanoi - deterministic
fprintf('Running experiments in the Hanoi domain (deterministic)\n');
tic; Vvi = HanoiRunner.vi(true); tvi = toc;
tic; Vpvi = HanoiRunner.plainVi(true); tpvi = toc;
assert(sum(abs(Vvi - Vpvi)) < 0.05);
tic; Voa = HanoiRunner.optionsAggregation(true); toa = toc;
assert(sum(abs(Vvi - Voa)) < 0.05);
fprintf('************************************************************\n');
fprintf('Summary of results in the Hanoi domain (deterministic).\n');
fprintf('Model value iteration: %.2f seconds.\n', tvi);
fprintf('Plain value iteration: %.2f seconds.\n', tpvi);
fprintf('Options and aggregation: %.2f seconds.\n', toa);
fprintf('************************************************************\n');


%% Hanoi - non-deterministic
fprintf('Running experiments in the Hanoi domain (non-deterministic)\n');
tic; Vvi = HanoiRunner.vi(false); tvi = toc;
tic; Vpvi = HanoiRunner.plainVi(false); tpvi = toc;
assert(sum(abs(Vvi - Vpvi)) < 0.05);
tic; Voa = HanoiRunner.optionsAggregation(false); toa = toc;
assert(sum(abs(Vvi - Voa)) < 0.20);
fprintf('************************************************************\n');
fprintf('Summary of results in the Hanoi domain (non-deterministic).\n');
fprintf('Model value iteration: %.2f seconds.\n', tvi);
fprintf('Plain value iteration: %.2f seconds.\n', tpvi);
fprintf('Options and aggregation: %.2f seconds.\n', toa);
fprintf('************************************************************\n');


%% Eight-Puzzke - deterministic
fprintf('Running experiments in the 8-puzzle domain (deterministic)\n');
tic; [As,ep] = EightPuzzleRunner.prepare(); tprep = toc;
tic; Vvi = EightPuzzleRunner.vi(As,ep); tvi = toc;
tic; Vpvi = EightPuzzleRunner.plainVi(As,ep); tpvi = toc;
assert(sum(abs(Vvi - Vpvi)) < 0.05);
tic; Voa123 = EightPuzzleRunner.optionsAggregation(...
                                    As,ep,[1 2 3],-1); toa123 = toc;
assert(sum(abs(Vvi - Voa123)) < 0.05);
tic; Voa123456 = EightPuzzleRunner.optionsAggregation(...
                           As,ep,[1 2 3 4 5 6],-1); toa123456 = toc;
assert(sum(abs(Vvi - Voa123456)) < 0.05);
tic; Voa12345678 = EightPuzzleRunner.optionsAggregation(...
                     As,ep,[1 2 3 4 5 6 7 8],-1); toa12345678 = toc;
assert(sum(abs(Vvi - Voa12345678)) < 0.05);
tic; Voa78 = EightPuzzleRunner.optionsAggregation(...
                                       As,ep,[7 8],-1); toa78 = toc;
assert(sum(abs(Vvi - Voa78)) < 0.05);
tic; Voa7 = EightPuzzleRunner.optionsAggregation(...
                                          As,ep,[7],-1); toa7 = toc;
assert(sum(abs(Vvi - Voa7)) < 0.05);
tic; Voa8 = EightPuzzleRunner.optionsAggregation(...
                                          As,ep,[8],-1); toa8 = toc;
assert(sum(abs(Vvi - Voa8)) < 0.05);
tic; Voa9 = EightPuzzleRunner.optionsAggregation(...
                                          As,ep,[9],-1); toa9 = toc;
assert(sum(abs(Vvi - Voa9)) < 0.05);
tic; Voa10 = EightPuzzleRunner.optionsAggregation(...
                                        As,ep,[10],-1); toa10 = toc;
assert(sum(abs(Vvi - Voa10)) < 0.05);
tic; Voa11 = EightPuzzleRunner.optionsAggregation(...
                                        As,ep,[11],-1); toa11 = toc;
assert(sum(abs(Vvi - Voa11)) < 0.05);
tic; Voa12 = EightPuzzleRunner.optionsAggregation(...
                                        As,ep,[12],-1); toa12 = toc;
assert(sum(abs(Vvi - Voa12)) < 0.05);
tic; Voa13 = EightPuzzleRunner.optionsAggregation(...
                                        As,ep,[13],-1); toa13 = toc;
assert(sum(abs(Vvi - Voa13)) < 0.05);
tic; Voa14 = EightPuzzleRunner.optionsAggregation(...
                                        As,ep,[14],-1); toa14 = toc;
assert(sum(abs(Vvi - Voa14)) < 0.05);
tic; Voa15 = EightPuzzleRunner.optionsAggregation(...
                                        As,ep,[15],-1); toa15 = toc;
assert(sum(abs(Vvi - Voa15)) < 0.05);
tic; Voac = EightPuzzleRunner.optionsChain(As,ep); toac = toc;
assert(sum(abs(Vvi - Voac)) < 0.05);
tic; Voa10h = EightPuzzleRunner.optionsAggregation(...
                                        As,ep,[10],9); toa10h = toc;
assert(sum(abs(Vvi - Voa10h)) < 0.05);

fprintf('************************************************************\n');
fprintf('Summary of results in the 8-puzzle domain (deterministic).\n');
fprintf('Generating actions: %.2f seconds.\n', tprep);
fprintf('Model value iteration: %.2f seconds.\n', tvi);
fprintf('Plain value iteration: %.2f seconds.\n', tpvi);
fprintf('Options+aggreg(subgoals:1,2,3): %.2f s\n', toa123);
fprintf('Options+aggreg(subgoals:1,2,3,4,5,6): %.2f s\n', toa123456);
fprintf('Options+aggreg(subgoals:1,2,3,4,5,6,7,8): %.2f s\n', toa12345678);
fprintf('Options+aggreg(subgoals:7,8): %.2f s\n', toa78);
fprintf('Options+aggreg(subgoals:7): %.2f s\n', toa7);
fprintf('Options+aggreg(subgoals:8): %.2f s\n', toa8);
fprintf('Options+aggreg(subgoals:9): %.2f s\n', toa9);
fprintf('Options+aggreg(subgoals:10): %.2f s\n', toa10);
fprintf('Options+aggreg(subgoals:11): %.2f s\n', toa11);
fprintf('Options+aggreg(subgoals:12): %.2f s\n', toa12);
fprintf('Options+aggreg(subgoals:13): %.2f s\n', toa13);
fprintf('Options+aggreg(subgoals:14): %.2f s\n', toa14);
fprintf('Options+aggreg(subgoals:15): %.2f s\n', toa15);
fprintf('Options+aggreg(subgoals 1,4->7, 1->8): %.2f s\n', toac);
fprintf('Options+aggreg(subgoal 10, horizon 9): %.2f s\n', toa10h)
fprintf('************************************************************\n');

