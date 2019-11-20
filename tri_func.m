function x = tri_func(t,D,V,Tm,T_n,BW)
% t -> �ð���
% D -> �����ð�
% Tm -> ���� �ֱ�
% T_n -> �ð��� ���Ұ���
% t1 = 0;       % �ð��� ����
% t2 = 0.0625;        % �ð��� ��
% T_n = 10000;        % �ð��� ���Ұ���
% t = linspace(t1,t2,T_n+1);
% dt = t(2)-t(1);
% Tm = 0.03125;       % ���� �ֱ�(�ð�) / ������ȣ �ֱ� [sec]

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