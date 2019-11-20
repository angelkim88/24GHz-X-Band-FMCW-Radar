clear all; 
close all;

%----- �⺻���� -----%
c = 3e8;            % ���Ǽӵ� [m/s]
fstart = 0e6; %(Hz) LFM start frequency for example
fstop = 30e6; %(Hz) LFM stop frequency for example
B = fstop-fstart; %(Hz) transmti bandwidth  �뿪�� - 30[MHz]
Tm = 0.001;         % �����ð�
fc = 24e9;        % �߽����ļ�[Hz] -> 9.41[GHz]
wc = 2*pi*fc;       % �߽����ļ� ���ӵ�[rad/sec]

for j=1:2
    
%----- �ð��� ���� -----%
if j==1
    t_s = 0;                        % �ð��� ����
    t_e = Tm;                    % �ð��� ��
elseif j==2
    t_s = t_e;                        % �ð��� ����
    t_e = t_s+Tm;                    % �ð��� ��
end
t_n = 9000; %5000;%2516;                     % �ð��� ���Ұ���%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t = linspace(t_s,t_e,t_n+1);    % �ð��� ����
t_d = t(2)-t(1);                % �ð��� ���� ����


%----- ���� ����� �ӵ� �� �Ÿ� -----%
d = 0;              % ������ �Ÿ�(m)
v = 0;              % ������ �ӵ�(m/s)
d_obj = 100;        % ���� ��� �Ÿ�(m)
v_obj = 22;%22.222222;          % ���� ��� �ӵ�(m/s)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
D = (2*d)/c;
V = (2*v)/c;
D_obj = (2*d_obj)/c;
V_obj = (4*fc*v_obj)/c;


%----- ������ȣ ���� -----%
fm = 1/(2*Tm);
mt = tri_func(t,D,V,Tm*2,t_n,B);    % �۽� ������ȣ
%mt = tri_func(t,0,0,Tm*2,t_n,B);    % �۽� ������ȣ
mr = tri_func(t,D_obj,V_obj,Tm*2,t_n,B);	% ���� ������ȣ


%----- �������� ���� ��� -----%
integ_mt(1) = 0;
for i=1:length(t)-1     % �۽� ������ȣ ����
    integ_mt(i+1)=integ_mt(i)+mt(i)*t_d;
end
integ_mr(1) = 0;
for i=1:length(t)-1     % ���� ������ȣ ����
    integ_mr(i+1)=integ_mr(i)+mr(i)*t_d;
end

% % ----- ����þ� ���� ���� -----%
% % ��� 2, �л� 10
% N = rand(1,t_n+1).*sqrt(1) + 2;


%----- ���ļ� ���� ��ȣ -----%
St = cos(2*pi.*(fc.*t+integ_mt));
Sr = cos(2*pi.*(fc.*(t-D_obj) + integ_mr));


%----- �۽Ž�ȣ�� ���Ž�ȣ �� -----%
%SM = s_m1.*S_M2;
Sm = St.*Sr;


%----- ���ø� ���� ���� ���� -----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fs = 2.52e6;%2.52e6;          % ���ø� ���ļ� [Hz]
%ws = 2*pi*Fs;       % ���ø� ���ӵ� [rad/sec]


%----- low-pass filter -----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Ts = 1/Fs;
n=5; % ������ �����ָ� �ȴ�.
Wn=22000;	% cut off frequency
Fn=Fs/2;	% Nyquist frequency
ftype='low';
[b, a]=butter(n, Wn/Fn, ftype);
y=filter(b,a,Sm);	% y�� filtering�� ��ȣ


%----- low-pass filter�� ����� ���Ž�ȣ ���� -----%
y2 = cos(((4*pi*d_obj)/(c*Tm))*((B*t)+fc));


%----- FFT -----%
[YfreqDomain,frequencyRange] = positiveFFT(y,Fs);


%----- FFT2 -----%
[YfreqDomain2,frequencyRange2] = positiveFFT(y2,Fs);


%----- beat frequency -----%
k = find(abs(YfreqDomain)>=max(abs(YfreqDomain)));
if j==1
    f_bu = frequencyRange(k)
elseif j==2
    f_bd = frequencyRange(k)
end


%----- beat frequency -----%
k = find(abs(YfreqDomain2)>=max(abs(YfreqDomain2)));
if j==1
    f_bu2 = frequencyRange2(k)
elseif j==2
    f_bd2 = frequencyRange2(k)
end


%----- ȭ�� ��� -----%
figure(1);
if j==1
    subplot(1,2,1)
    hold on;
    plot(t,mt)          % �۽� ������ȣ
    plot(t,mr,'r')          % ���� ������ȣ
    rangey = max(mt)-min(mt);
    axis([t_s, t_e, 0, B]);
    title('��±���');
    grid
elseif j==2
    subplot(1,2,2)
    hold on;
    plot(t,mt)          % �۽� ������ȣ
    plot(t,mr,'r')          % ���� ������ȣ
    rangey = max(mt)-min(mt);
    axis([t_s, t_e, 0, B]);
    title('�ϰ�����');
    grid
end

figure(2);
if j==1
    subplot(2,2,1)
    plot(t,St)          % �۽� ������ȣ
    axis([t_s, t_e, -1.2, 1.2]);
    title('��±��� chirp �۽Ž�ȣ');
    subplot(2,2,2)
    plot(t,Sr)          % �۽� ������ȣ
    axis([t_s, t_e, -1.2, 1.2]);
    title('��±��� chirp ���Ž�ȣ');
    grid
elseif j==2
    subplot(2,2,3)
    plot(t,St)          % �۽� ������ȣ
    axis([t_s, t_e, -1.2, 1.2]);
    title('�ϰ����� chirp �۽Ž�ȣ');
    subplot(2,2,4)
    plot(t,Sr)          % �۽� ������ȣ
    axis([t_s, t_e, -1.2, 1.2]);
    title('�ϰ����� chirp ���Ž�ȣ');
    grid
end

figure(3);
if j==1
    subplot(2,1,1)
    plot(t,Sm)          % �۽� ������ȣ
    title('��±��� �۽Ž�ȣ�� ���Ž�ȣ �� Sm');
    grid
elseif j==2
    subplot(2,1,2)
    plot(t,Sm)          % �۽� ������ȣ
    title('�ϰ����� �۽Ž�ȣ�� ���Ž�ȣ �� Sm');
    grid
end

figure(4);
if j==1
    subplot(2,1,1)
    plot(t,y)          % �۽� ������ȣ
    title('��±��� Sm�� low-pass filter�� ����� ���');
    grid
elseif j==2
    subplot(2,1,2)
    plot(t,y)          % �۽� ������ȣ
    title('�ϰ����� Sm�� low-pass filter�� ����� ���');
    grid
end

figure(5);
if j==1
    subplot(2,1,1)
    plot(t,y2)          % �۽� ������ȣ
    title('�������� ������ ��±��� low-pass filter�� ����� ���');
    grid
elseif j==2
    subplot(2,1,2)
    plot(t,y2)          % �۽� ������ȣ
    title('�������� ������ �ϰ����� low-pass filter�� ����� ���');
    grid
end

figure(6);
if j==1
    %subplot(2,1,1)
    plot(frequencyRange,abs(YfreqDomain));% �۽� ������ȣ
    hold on;
    xlabel('Freq (Hz)')
    ylabel('Amplitude')
    title('up-beat ��ȣ�� FFT ���');
    grid
    axis([0,f_bu+(f_bu*2),0,max(abs(YfreqDomain))+(max(abs(YfreqDomain))*0.3)])
elseif j==2
    %subplot(2,1,2)
    plot(frequencyRange,abs(YfreqDomain),'r');          % �۽� ������ȣ
    xlabel('Freq (Hz)')
    ylabel('Amplitude')
    title('down-beat ��ȣ�� FFT ���');
    grid on;
    axis([0,f_bu+(f_bu*2),0,max(abs(YfreqDomain))+(max(abs(YfreqDomain))*0.3)])
end

figure(7);
if j==1
    %subplot(2,1,1)
    plot(frequencyRange2,abs(YfreqDomain2));          % �۽� ������ȣ
    hold on;
    xlabel('Freq (Hz)')
    ylabel('Amplitude')
    title('�������� ������ up-beat ��ȣ�� FFT ���');
    grid
    axis([0,f_bu2+(f_bu2*2),0,max(abs(YfreqDomain2))+(max(abs(YfreqDomain2))*0.3)])
elseif j==2
    %subplot(2,1,2)
    plot(frequencyRange,abs(YfreqDomain),'r');          % �۽� ������ȣ
    xlabel('Freq (Hz)')
    ylabel('Amplitude')
    title('�������� ������ down-beat ��ȣ�� FFT ���');
    grid on
    axis([0,f_bd2+(f_bu*2),0,max(abs(YfreqDomain))+(max(abs(YfreqDomain))*0.3)])
end

end


%----- �Ÿ� �� �ӵ� ��� -----%
fr=(f_bd+f_bu)/2
fd=(f_bd-f_bu)/2

R= (c*Tm*fr)/(2*B)
V_msec=(c*fd)/(2*fc)