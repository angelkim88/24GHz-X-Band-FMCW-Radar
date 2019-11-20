function x = tri_func(t,D,V,Tm,T_n,BW)
% t -> 시간축
% D -> 지연시간
% Tm -> 변조 주기
% T_n -> 시간축 분할개수
% t1 = 0;       % 시간축 시작
% t2 = 0.0625;        % 시간축 끝
% T_n = 10000;        % 시간축 분할개수
% t = linspace(t1,t2,T_n+1);
% dt = t(2)-t(1);
% Tm = 0.03125;       % 변조 주기(시간) / 정보신호 주기 [sec]

t = t-D;

a = fix(t/(Tm/2));
b = mod(a,2);
c = fix(a/2);

for i = 1:T_n+1;
    
  if t(i) > 0
    if b(i) == 0
        x(i) = (BW*((2/Tm)*(t(i)-(c(i)*Tm)))+V);
    elseif b(i) == 1
        x(i) = (BW*(2-((2/Tm)*(t(i)-(c(i)*(Tm)))))+V);
    end
  else
      x(i) = 0;
  end
end