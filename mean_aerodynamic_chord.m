%Mean Aerodynamic Chord Calculation for MATLAB/OCTAVE(v.20200430)
%By SV-001/R

%README

%If you want to use exact coordinate of wing planform, use Method #1.
%If you know formula of leading and trailing edge line, switch to Method #2 using block comments.

%Coordinate orientation:
%X axis: longitudinal axis of aircraft (roll axis)
%Y axis: lateral axis of aircraft (pitch axis)
%Z axis: vertical axis of aircraft (yaw axis)

%X coordinate is distance from datum line along centerline of aircraft.
%Y coordinate is horizontal distance from centerline


%==================== Method #1 (Coordinate) ====================
%Insert coordinate of leading edge and trailing edge points.
%More points would give you good result, but calculation time may increases.
%You may get "ABNORMAL RETURN FROM DQAGP" error message while calculating. Then raise absolute tolerance of quad function.

le_y = [0, 2.683, 5.869, 5.975, 6.046, 6.104, 6.150, 6.196, 6.238, 6.269, 6.298, 6.317, 6.336, 6.353, 6.362]; %y position of leading edge points
le_x = [0, 0, -0.151, -0.205, -0.255, -0.307, -0.358, -0.422, -0.494, -0.561, -0.638, -0.707, -0.789, -0.902, -1.009]; %x position of leading edge points
te_y = [0, 2.683, 5.869, 5.975, 6.046, 6.104, 6.150, 6.196, 6.238, 6.269, 6.298, 6.317, 6.336, 6.353, 6.362]; %y position of trailing edge points
te_x = [-1.913, -1.913, -1.495, -1.459, -1.428, -1.397, -1.367, -1.332, -1.293, -1.257, -1.216, -1.180, -1.137, -1.076, -1.009]; %x position of trailing edge points

%Leading edge formula (You don't have to edit this.)
le_line = @(y) interp1(le_y, le_x, y, 'linear');

%Trailing edge formula (You don't have to edit this.)
te_line = @(y) interp1(te_y, te_x, y, 'linear');
%====================== End of Method #1 ========================

%{
%==================== Method #2 (Formula) =======================
%Sample case: Spitfire 
%Leading edge formula
le_line = @(y) sqrt(1 - (y/222.5).^2).*(14.5*(1 - (1 - (y/222.5).^2).^0.72).^1.57 + 35.5) - 35.5;

%Trailing edge formula
te_line = @(y) sqrt(1 - (y/222.5).^2).*(14.5*(1 - (1 - (y/222.5).^2).^0.72).^1.57 - 64.5) - 35.5;

%Coordinate of start and end points of leading edge and trailing edge
%You should input Y positions of wing root and tip. (just 2 points only!)
le_y = [0,222.5]; %Y position of leading edge line points
le_x = [le_line(le_y(1)),le_line(le_y(end))]; %X position of leading edge line points (You don't have to edit this.)
te_y = [0,222.5]; %Y position of trailing edge line points
te_x = [te_line(te_y(1)),te_line(te_y(end))]; %X position of trailing edge line points (You don't have to edit this.)
%====================== End of Method #2 ========================
%}

%Aerodynamic Center of airfoil
ac = 1/4;

%You don't have to edit below.
%Basic form factors
S = 2*abs(quad(te_line, te_y(1), te_y(end), 1e-4) - quad(le_line, le_y(1), le_y(end), 1e-4)); %wing area
b = max(le_y(end), te_y(end)); %wing span
c_r = abs(le_x(1) - te_x(1)); %root chord
c_t = abs(le_x(end) - te_x(end)); %tip chord

%Calculating MAC and its position
MAC = (2/S)*quad(@(y) (le_line(y) - te_line(y)).^2, le_y(1), le_y(end), 1e-4); %length of mean aerodynamic center
y_MAC = (2/S)*quad(@(y) (le_line(y) - te_line(y))*y, le_y(1), le_y(end), 1e-4); %Y position of MAC
le_MAC = (2/S)*quad(@(y) le_line(y)*(le_line(y) - te_line(y)), le_y(1), le_y(end), 1e-4); %leading edge X position of MAC (LEMAC)
te_MAC = (2/S)*quad(@(y) te_line(y)*(le_line(y) - te_line(y)), te_y(1), te_y(end), 1e-4); %trailing edge X position of MAC (TEMAC)
x_ac_MAC = (2/S)*quad(@(y) (le_line(y) - ac*(le_line(y) - te_line(y)))*(le_line(y) - te_line(y)), le_y(1), le_y(end), 1e-4);%X position of aerodynamic center

%Plotting results
fprintf('Total Wing Area\t\t\t\t\t= %.2f\n', S)
fprintf('Total Wing Span\t\t\t\t\t= %.2f\n', b)
fprintf('Chord of Wing Root\t\t\t\t= %.2f\n', c_r)
fprintf('Chord of Wing tip\t\t\t\t= %.2f\n', c_t)
fprintf('Mean Aerodynamic Chord\t\t\t\t= %.2f\n', MAC)
fprintf('y Position of MAC (horizontal distance)\t\t= %.2f\n', y_MAC)
fprintf('x Position of Leading Edge of MAC\t\t= %.2f\n', le_MAC)
fprintf('x Position of Trailing Edge of MAC\t\t= %.2f\n', te_MAC)
fprintf('x Position of Aerodynamic Center(%.1f%% MAC)\t= %.2f\n', 100*ac, x_ac_MAC)

figure('Name','Wing Planform','NumberTitle','off')
plot([0:0.01:le_y(end)], le_line([0:0.01:le_y(end)]), [0:0.01:te_y(end)], te_line([0:0.01:te_y(end)]), y_MAC, x_ac_MAC, 'ko')
axis equal
set(gca, 'XaxisLocation', 'origin', 'YaxisLocation', 'origin');
line([le_y(end), te_y(end)], [le_x(end), te_x(end)])
line([le_y(1), te_y(1)], [le_x(1), te_x(1)])
line([y_MAC, y_MAC], [le_MAC, te_MAC])
line([y_MAC, y_MAC], [le_MAC, 0], 'linestyle', '--', 'color', 'k')
text(y_MAC, le_MAC, sprintf('Dist=%.2f', y_MAC), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top')
line([y_MAC, 0], [le_MAC, le_MAC], 'linestyle', '--', 'color', 'k')
text(y_MAC/2, le_MAC, sprintf('LEMAC=%.2f', le_MAC), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top')
line([y_MAC, 0], [te_MAC, te_MAC], 'linestyle', '--', 'color', 'k')
text(y_MAC/2, te_MAC, sprintf('TEMAC=%.2f', te_MAC), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
line([y_MAC, 0], [x_ac_MAC, x_ac_MAC], 'linestyle', '--', 'color', 'k')
text(y_MAC/2, x_ac_MAC, sprintf('%.1f%% MAC=%.2f', 100*ac, x_ac_MAC), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
text((le_y(1) + le_y(end))/2, le_line((le_y(1) + le_y(end))/2), 'Leading Edge', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
text((te_y(1) + te_y(end))/2, te_line((le_y(1) + te_y(end))/2), 'Trailing Edge', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top')
text((le_y(1) + te_y(1))/2, (le_x(1) + te_x(1))/2, sprintf('Root=%.2f', c_r))
text((le_y(end) + te_y(end))/2, (le_x(end) + te_x(end))/2, sprintf('Tip=%.2f', c_t))
text(y_MAC, x_ac_MAC, sprintf('Aerodynamic Center'), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top')
text(y_MAC, (le_MAC + te_MAC)/2, sprintf('MAC=%.2f', MAC), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top')
text((le_y(1) + le_y(end))/2, abs(le_x(1) - te_x(1))/4, sprintf('Area(Both)=%.2f', S), 'HorizontalAlignment', 'center')
text(le_y(end), abs(le_x(1) - te_x(1))/4, sprintf('Span(Both)=%.2f', b), 'HorizontalAlignment', 'right')
text(0, abs(le_x(1) - te_x(1))/4, '\leftarrowCenterline (X axis)')
box off