clc
clear
close all

%arguments
bit_num = 4;
clock_cycle_num = 16000;

%REPLACE CLOCK CYCLE WITH 'C' LATER ON BEFORE APPLYING THE SIGNAL.
clockCycle = 1:1:clock_cycle_num;
clockCycleSize = size(clockCycle);

divide16 = zeros(size(clockCycle));
lsb = divide16;
mid = lsb;
msb = lsb;

lsb_value = lsb;
mid_value = lsb;
msb_value = lsb;

lsb_value_bin = zeros(clockCycleSize(2),bit_num);
mid_value_bin = zeros(clockCycleSize(2),bit_num);
msb_value_bin = zeros(clockCycleSize(2),bit_num);

digit1 = lsb;
digit2 = lsb;
digit3 = lsb;

D_out = zeros(clockCycleSize(2),bit_num);

dp = lsb;

%divide by 16 generation clock
for i = 1:clockCycleSize(2)
    if (mod(i,16)==0 && i~=0)
        divide16(i)=1;
    end
end

%lsb generation
counterLSB = 0;
for i = 1:clockCycleSize(2)
    if (divide16(i) == 1)
        counterLSB = counterLSB + 1;
    end
    if (counterLSB == 10)
        counterLSB = 0;
        lsb(i) = 1;
    end
    
    lsb_value(i) = counterLSB;
    lsb_value_holder = de2bi(counterLSB,bit_num);
    
    for j = 1:bit_num
        lsb_value_bin(i,j) = lsb_value_holder(j);
    end
end

%mid generation
counterMid = 0;
for i = 1:clockCycleSize(2)
    if (lsb(i) == 1)
        counterMid = counterMid + 1;
    end
    if (counterMid == 10)
        counterMid = 0;
        mid(i) = 1;
    end
    mid_value(i) = counterMid;
    mid_value_holder = de2bi(counterMid,bit_num);
    
    for j = 1:bit_num
        mid_value_bin(i,j) = mid_value_holder(j);
    end
end

%msb generation
counterMsb = 0;
for i = 1:clockCycleSize(2)
    if (mid(i) == 1)
        counterMsb = counterMsb + 1;
    end
    if (counterMsb == 10)
        counterMsb = 0;
        msb(i) = 1;
    end
    msb_value(i) = counterMsb;
    msb_value_holder = de2bi(counterMsb,bit_num);
    
    for j = 1:bit_num
        msb_value_bin(i,j) = msb_value_holder(j);
    end
end

%Testing the output of a digit.
counterHolder = 1;
for i = 1:clockCycleSize(2)
    counterHolder = counterHolder+1;
    if(counterHolder == 1)
        digit1(i) = 1;
    elseif (counterHolder == 2)
        digit2(i) = 1;
    elseif (counterHolder == 3)
        counterHolder = 0;
        digit3(i) = 1;
    end
end

%dp output (active low)
dp = digit1+digit3;


% %ploting
% figure
% subplot(3,3,1);
% plot(clockCycle,lsb);
% title('LSB');
% 
% subplot(3,3,2);
% plot(clockCycle,mid);
% title('MID');
% 
% subplot(3,3,3);
% plot(clockCycle,msb);
% title('MSB');
% 
% subplot(3,3,4);
% plot(clockCycle,lsb_value);
% title('LSB');
% 
% subplot(3,3,5);
% plot(clockCycle, mid_value);
% title('MID VALUE');
% 
% subplot(3,3,6);
% plot(clockCycle, msb_value);
% title('MSB VALUE');
% 
% subplot(3,3,7);
% plot(clockCycle,digit1);
% hold on;
% plot(clockCycle,digit2);
% plot(clockCycle,digit3);
% hold off;
% title('DIGIT1, DIGIT2, DIGIT3');
% 
% subplot(3,3,8);
% plot(clockCycle, dp);
% title('DP');
% 
% figure
% subplot(3,4,1);
% plot(clockCycle, lsb_value_bin(:,4));
% title('LSB value b3 ');
% 
% subplot(3,4,2);
% plot(clockCycle, lsb_value_bin(:,3));
% title('LSB value b2 ');
% 
% subplot(3,4,3);
% plot(clockCycle, lsb_value_bin(:,2));
% title('LSB value b1 ');
% 
% subplot(3,4,4);
% plot(clockCycle, lsb_value_bin(:,1));
% title('LSB value b0 ');

%output multiplexed
for i = 1:clockCycleSize(2)
    if(digit1(i))
        D_out(i,:) = msb_value_bin(i,:);
    elseif (digit2(i))
        D_out(i,:) = mid_value_bin(i,:);
    elseif (digit3(i))
        D_out(i,:) = lsb_value_bin(i,:);
    end
end

%digit controller 
digit = [digit1; digit2; digit3; dp]';

%concatenate the whole system
output_sequence = [digit D_out]';

%printing to file
fileID = fopen('mainSeqTestVect.vec', 'w');
%Header
fprintf(fileID,'#Main Sequencer test vector\r\n');
fprintf(fileID,'<PinDef>\r\n');
fprintf(fileID,'A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,A11,A12,A13,A14,A15,A16,A17,A18,A19,A20,A21,A22,A23,Q0,Q1,Q2,Q3,Q4,Q5,Q6,Q7,Q8,Q9,Q10,Q11,Q12,Q13,Q14,Q15,Q16,Q17,Q18,Q19,Q20,Q21,Q22,Q23\r\n');
fprintf(fileID,'</Pindef>\r\n');
fprintf(fileID,'<TestVector>\r\n');
fprintf(fileID,'\r\n# A[0:7]  A[8:15] A[16:23]   Q[0:7]  Q[8:15] Q[16:23]\r\n');

% A[0:7]  A[8:15] A[16:23]   Q[0:7]  Q[8:15] Q[16:23]
formatSpec = 'XXXXXXXX XXXXXC1X X11XXXXX  XXXXXXX%d %d%d00%d%d%d%d %dXXXXXXX\r\n'; 
fprintf(fileID, 'XXXXXXXX XXXXX00X X11XXXXX  XXXXXXX1 00001000 0XXXXXXX\r\n');
fprintf(fileID, formatSpec, output_sequence);
fprintf(fileID, '</TestVector>\r\n #End of the test vector file');
fclose(fileID);

