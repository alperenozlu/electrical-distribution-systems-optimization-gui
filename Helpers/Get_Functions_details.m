function [lb,ub,dim,params,fobj] = Get_Functions_details(F,params)

switch F
    case 'F99'
        fobj = @F99;
        lb = double(reshape(params{11}(:,3),1,[]));
        ub = double(reshape(params{11}(:,4),1,[]));
        dim= size(params{11},1);
        params = params;
     case 'F100'
        fobj = @F100;
        lb = double(reshape(params{11}(:,3),1,[]));
        ub = double(reshape(params{11}(:,4),1,[]));
        dim= size(params{11},1);
        params = params;
end
end

% F99
function [fitness,UpdatedPositions]=F99(Positions, params)

testCaseName = params{1};
time = params{2};
pvBuses = params{3};
pvOutputCount = params{7};
dayTimeLoads = params{8};
dayTimePvOutputLoadVal = params{9};
dayTimePvOutputLoadValues = dayTimePvOutputLoadVal;

% initial values
dayTimeLoadValue = dayTimeLoads(time);
dayTimePvOutputLoadValue =  dayTimePvOutputLoadValues(time);


pvAndTapChangerTable = params{11};
TapPositions = [];

[Py,Qy,BR]=GetCaseData(testCaseName);

Py = Py * dayTimeLoadValue;
Qy = Qy * dayTimeLoadValue;

% set vector for tap changer location & positions
for iii = 1:size(pvAndTapChangerTable,1)
    line = pvAndTapChangerTable(iii,:);
    if line(1) == "tc"
       Positions(1,iii) = round(Positions(1,iii));
       newLine = [str2num(line(2)) Positions(1,iii)];
       TapPositions  = [TapPositions;newLine];
    end
end

for j = 1:length(pvBuses)
    currentBus = pvBuses(j);
	value = Positions(1,j); % reactive power
    Py(currentBus) = Py(currentBus) + (pvOutputCount * dayTimePvOutputLoadValue);

    if(value < 0)
        Qy(currentBus) = Qy(currentBus) + value;
    else
        Qy(currentBus) = Qy(currentBus) - value;
    end
end

voltage = CalculateVoltage(Py,Qy,BR,TapPositions);
fitness =  sum(abs(1-voltage).^2);
UpdatedPositions = Positions;
end

% F100
function [fitness,UpdatedPositions] = F100(Positions, params)
DailyLoads = params{8};
Locations = params{10};
Battery_Locations = params{12};
Dim = 24; % 24 hour

BatteryLB = params{16}(1);
BatteryUB = params{16}(2);
BatteryCurrentValue = params{15};
BatteryStep = params{14};

EditedPositions = reshape(Positions,[], (length(Locations)+ length(Battery_Locations)))';

% Normalization for the batteries

for ttt = 1:(length(Locations)+length(Battery_Locations))
    %% that means its battery
    if ttt > length(Locations)
        
        BatteryCurrentValue = params{15};
        
        for iii = 1:24
            currentPosition = EditedPositions(ttt,iii);
            
            chargeMode = 1; % charging
            if currentPosition < -0.5
                chargeMode =  -1; % decharging
            end
            
            BatteryNextValue = BatteryCurrentValue + (BatteryStep * chargeMode);
            
            if( BatteryNextValue <= BatteryUB && BatteryNextValue >= BatteryLB)
                EditedPositions(ttt,iii) = chargeMode;
                BatteryCurrentValue = BatteryNextValue;
            else
                chargeMode = -1 * chargeMode;
                EditedPositions(ttt,iii) = chargeMode;
                BatteryCurrentValue = BatteryCurrentValue + (BatteryStep * chargeMode);
            end
        end
        
    end
end

% End of the normalization for the batteries
totalVoltages = [];
% Calculating the voltage levels
for iii = 1:24
    
    [Py,Qy,BR] = GetCaseData(params{1});
    Py = Py * DailyLoads(iii);
    Qy = Qy * DailyLoads(iii);
    
    
    CurrentTimeTapLocations = zeros(length(Locations), 2); % 2 sabit olacak.
    
    for ttt = 1:length(Locations)
        EditedPositions(ttt,iii) = round(EditedPositions(ttt,iii));
        CurrentTimeTapLocations(ttt,:) = [Locations(ttt) EditedPositions(ttt,iii)];
    end
    
    
    for jjj = 1:length(Battery_Locations)
        zzz = (length(Locations) + jjj);
        currentBatteryPowerAtThisTime = EditedPositions(zzz,iii);
        busLocation = Battery_Locations(jjj);
        Py(busLocation) = Py(busLocation) - (params{13} *  BatteryStep * currentBatteryPowerAtThisTime);
    end
    
    voltage = CalculateVoltage(Py,Qy,BR,CurrentTimeTapLocations); % we calculate the voltage for every hour 
    totalVoltages(:,iii) = voltage;
    
end
% End of the voltage levels

fitness = sum(sum(abs(1-totalVoltages).^2)); % It is different from the previous objective function because we are doing 24-hour work. 
UpdatedPositions = reshape(EditedPositions',1,[]);
end
