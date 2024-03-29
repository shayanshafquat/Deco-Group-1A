function bandpassed
    
    function C = C_data
        data = load("C78.mat");
        C = data.C;
    end

       
    
C = C_data;
C = C*0.2/max(max(C));
tmax = 10;
dt = 1/1000;
num_steps = [0:dt:tmax];
P.a = 0;
omegas = [4 12 28]*2*pi;
P.omega = 24*pi;
P.beta = 0.5;
betas=[0.5];
P.G = 0.5;
freq=[10 14];
Freq=num2str(freq);

% Initialize the arrays to store the x, y values for all neurons
x_values = zeros(length(C),length(num_steps));
y_values = zeros(length(C),length(num_steps));

% Initialize x and y vectors with zeros
x = ones(length(C),1)*0.5;
y = ones(length(C),1)*0.5;

laplac= C - diag(sum(C,1));

for i=1:length(betas)
    
    P.beta=betas(i);

    for o=1:length(omegas)
      
        P.omega = omegas(o);

        freq_str = num2str(P.omega/(2*pi));

        bandpass_range = [P.omega/(2*pi)-2 P.omega/(2*pi)+2];
        bandpass_str = num2str(bandpass_range);

        
    for step = 1:length(num_steps)
    
        % Generate a single random noise term for each neuron
        P.noise = randn(length(C),1)*sqrt(dt);
    
        % Calculate the dxdt and dydt using the equations provided
        
        % dxdt = (P.a - x.^2 - y.^2).*x - P.omega*y + (P.G*(diag(C.*(x - x'))))';
        % dydt = (P.a - x.^2 - y.^2).*y + P.omega*x + (P.G*(diag(C.*(y - y'))))';
    
       
        
        dxdt = (P.a - x.^2 - y.^2).*x - P.omega*y + P.G*laplac*x;
        dydt = (P.a - x.^2 - y.^2).*y + P.omega*x + P.G*laplac*y;
    
        % Update the x and y values
        x = x+dxdt*dt+P.beta*P.noise;
        y = y+dydt*dt+P.beta*P.noise;
    
        % Store the values
        x_values(:,step) = x;
        y_values(:,step) = y;
    
    end
    
    

    figure(o);
    
    clf

    subplot(2,1,1)

    plot(num_steps,x_values(25,:))
    hold on
    ylabel('x(t)')
    title('Fundamental Frequency: ', freq_str)
    % legend(['\beta = ',num2str(P.beta)])

    subplot(2,1,2)
    
    filtered_x_val = bandpass(x_values', freq, 2/dt);
    
    plot(num_steps,filtered_x_val(:,25))
    
    hold on

    [yupper,ylower] = envelope(filtered_x_val);

    plot(num_steps,yupper(:,25))
    
    xlabel('Time (s)')
    ylabel('x(t)')
    legend('x(t)','envelope')
    title('Bandpassed region: ', bandpass_str)
    
    end

    filtered_x_val=bandpass(x_values',[10 14],2/dt);

    [yupper,ylower]=envelope(filtered_x_val);


    low_passed_envelope=lowpass(yupper,0.2,2/dt);
    size(filtered_x_val(:,25))

    figure(2)

    subplot(length(betas),1,i)

    plot(num_steps,low_passed_envelope(:,25))
    xlabel('time')
    ylabel('x(t)')
    title('Low-Passed Filter')

end

figure(1)
subplot(length(betas),2,1)
title('ODE Solutions to System of Equations')
subplot(length(betas),2,2)
title('ODE Solutions to System of Equations, Bandpassed at: ', Freq)

figure(3)
clf
plot(num_steps,yupper(:,25),'linewidth',4)
xlabel('Time (s)')
ylabel('x(t)')
title('Amplitude Envelope')

end
