close all

n = 230;
d = 3;
lambdas = 10.^(-5:0.1:8);

dfs = whitsm_EffectiveDims(n, d, lambdas);

semilogx(lambdas, dfs); grid on
xlabel('lambda');
ylabel('freedom of parameters')