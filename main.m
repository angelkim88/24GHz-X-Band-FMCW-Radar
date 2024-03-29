clear all; 
close all;

%----- 기본설정 -----%
c = 3e8;            % 빛의속도 [m/s]
fstart = 0e6; %(Hz) LFM start frequency for example
fstop = 30e6; %(Hz) LFM stop frequency for example
B = fstop-fstart; %(Hz) transmti bandwidth  대역폭 - 30[MHz]
Tm = 0.001;         % 변조시간
fc = 24e9;        % 중심주파수[Hz] -> 9.41[GHz]
wc = 2*pi*fc;       % 중심주파수 각속도[rad/sec]

for j=1:2
    
%----- 시간축 생성 -----%
if j==1
    t_s = 0;                        % 시간축 시작
    t_e = Tm;                    % 시간축 끝
elseif j==2
    t_s = t_e;                        % 시간축 시작
    t_e = t_s+Tm;                    % 시간축 끝
end
t_n = 9000; %5000;%2516;                     % 시간축 분할개수%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t = linspace(t_s,t_e,t_n+1);    % 시간축 생성
t_d = t(2)-t(1);                % 시간축 분할 간격


%----- 관측 대상의 속도 및 거리 -----%
d = 0;              % 관측자 거리(m)
v = 0;              % 관측자 속도(m/s)
d_obj = 100;        % 관측 대상 거리(m)
v_obj = 22;%22.222222;          % 관측 대상 속도(m/s)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
D = (2*d)/c;
V = (2*v)/c;
D_obj = (2*d_obj)/c;
V_obj = (4*fc*v_obj)/c;


%----- 정보신호 생성 -----%
fm = 1/(2*Tm);
mt = tri_func(t,D,V,Tm*2,t_n,B);    % 송신 정보신호
%mt = tri_func(t,0,0,Tm*2,t_n,B);    % 송신 정보신호
mr = tri_func(t,D_obj,V_obj,Tm*2,t_n,B);	% 수신 정보신호


%----- 변조공식 적분 계산 -----%
integ_mt(1) = 0;
for i=1:length(t)-1     % 송신 정보신호 적분
    integ_mt(i+1)=integ_mt(i)+mt(i)*t_d;
end
integ_mr(1) = 0;
for i=1:length(t)-1     % 수신 정보신호 적분
    integ_mr(i+1)=integ_mr(i)+mr(i)*t_d;
end

% % ----- 가우시안 잡음 생성 -----%
% % 평균 2, 분산 10
% N = rand(1,t_n+1).*sqrt(1) + 2;


%----- 주파수 변조 신호 -----%
St = cos(2*pi.*(fc.*t+integ_mt));
Sr = cos(2*pi.*(fc.*(t-D_obj) + integ_mr));


%----- 송신신호와 수신신호 곱 -----%
%SM = s_m1.*S_M2;
Sm = St.*Sr;


%----- 샘플링 관련 변수 설정 -----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fs = 2.52e6;%2.52e6;          % 샘플링 주파수 [Hz]
%ws = 2*pi*Fs;       % 샘플링 각속도 [rad/sec]


%----- low-pass filter -----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Ts = 1/Fs;
n=5; % 차수를 정해주면 된다.
Wn=22000;	% cut off frequency
Fn=Fs/2;	% Nyquist frequency
ftype='low';
[b, a]=butter(n, Wn/Fn, ftype);
y=filter(b,a,Sm);	% y가 filtering된 신호


%----- low-pass filter를 통과한 수신신호 공식 -----%
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


%----- 화면 출력 -----%
figure(1);
if j==1
    subplot(1,2,1)
    hold on;
    plot(t,mt)          % 송신 정보신호
    plot(t,mr,'r')          % 수신 정보신호
    rangey = max(mt)-min(mt);
    axis([t_s, t_e, 0, B]);
    title('상승구간');
    grid
elseif j==2
    subplot(1,2,2)
    hold on;
    plot(t,mt)          % 송신 정보신호
    plot(t,mr,'r')          % 수신 정보신호
    rangey = max(mt)-min(mt);
    axis([t_s, t_e, 0, B]);
    title('하강구간');
    grid
end

figure(2);
if j==1
    subplot(2,2,1)
    plot(t,St)          % 송신 정보신호
    axis([t_s, t_e, -1.2, 1.2]);
    title('상승구간 chirp 송신신호');
    subplot(2,2,2)
    plot(t,Sr)          % 송신 정보신호
    axis([t_s, t_e, -1.2, 1.2]);
    title('상승구간 chirp 수신신호');
    grid
elseif j==2
    subplot(2,2,3)
    plot(t,St)          % 송신 정보신호
    axis([t_s, t_e, -1.2, 1.2]);
    title('하강구간 chirp 송신신호');
    subplot(2,2,4)
    plot(t,Sr)          % 송신 정보신호
    axis([t_s, t_e, -1.2, 1.2]);
    title('하강구간 chirp 수신신호');
    grid
end

figure(3);
if j==1
    subplot(2,1,1)
    plot(t,Sm)          % 송신 정보신호
    title('상승구간 송신신호와 수신신호 곱 Sm');
    grid
elseif j==2
    subplot(2,1,2)
    plot(t,Sm)          % 송신 정보신호
    title('하강구간 송신신호와 수신신호 곱 Sm');
    grid
end

figure(4);
if j==1
    subplot(2,1,1)
    plot(t,y)          % 송신 정보신호
    title('상승구간 Sm의 low-pass filter를 통과한 결과');
    grid
elseif j==2
    subplot(2,1,2)
    plot(t,y)          % 송신 정보신호
    title('하강구간 Sm의 low-pass filter를 통과한 결과');
    grid
end

figure(5);
if j==1
    subplot(2,1,1)
    plot(t,y2)          % 송신 정보신호
    title('공식으로 생성한 상승구간 low-pass filter를 통과한 결과');
    grid
elseif j==2
    subplot(2,1,2)
    plot(t,y2)          % 송신 정보신호
    title('공식으로 생성한 하강구간 low-pass filter를 통과한 결과');
    grid
end

figure(6);
if j==1
    %subplot(2,1,1)
    plot(frequencyRange,abs(YfreqDomain));% 송신 정보신호
    hold on;
    xlabel('Freq (Hz)')
    ylabel('Amplitude')
    title('up-beat 신호의 FFT 결과');
    grid
    axis([0,f_bu+(f_bu*2),0,max(abs(YfreqDomain))+(max(abs(YfreqDomain))*0.3)])
elseif j==2
    %subplot(2,1,2)
    plot(frequencyRange,abs(YfreqDomain),'r');          % 송신 정보신호
    xlabel('Freq (Hz)')
    ylabel('Amplitude')
    title('down-beat 신호의 FFT 결과');
    grid on;
    axis([0,f_bu+(f_bu*2),0,max(abs(YfreqDomain))+(max(abs(YfreqDomain))*0.3)])
end

figure(7);
if j==1
    %subplot(2,1,1)
    plot(frequencyRange2,abs(YfreqDomain2));          % 송신 정보신호
    hold on;
    xlabel('Freq (Hz)')
    ylabel('Amplitude')
    title('공식으로 생성한 up-beat 신호의 FFT 결과');
    grid
    axis([0,f_bu2+(f_bu2*2),0,max(abs(YfreqDomain2))+(max(abs(YfreqDomain2))*0.3)])
elseif j==2
    %subplot(2,1,2)
    plot(frequencyRange,abs(YfreqDomain),'r');          % 송신 정보신호
    xlabel('Freq (Hz)')
    ylabel('Amplitude')
    title('공식으로 생성한 down-beat 신호의 FFT 결과');
    grid on
    axis([0,f_bd2+(f_bu*2),0,max(abs(YfreqDomain))+(max(abs(YfreqDomain))*0.3)])
end

end


%----- 거리 및 속도 계산 -----%
fr=(f_bd+f_bu)/2
fd=(f_bd-f_bu)/2

R= (c*Tm*fr)/(2*B)
V_msec=(c*fd)/(2*fc)
