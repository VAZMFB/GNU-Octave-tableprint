% Test for tableprint function
% Author: Milos D. Petrasinovic <mpetrasinovic@mas.bg.ac.rs>
% Structural Analysis of Flying Vehicles
% Faculty of Mechanical Engineering, University of Belgrade
% Department of Aerospace Engineering, Flying structures
% https://vazmfb.com
% Belgrade, 2021
% ---------------
%
% Copyright (C) 2021 Milos Petrasinovic <info@vazmfb.com>
%  
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as 
% published by the Free Software Foundation, either version 3 of the 
% License, or (at your option) any later version.
%   
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%   
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.
%
% ---------------
close all, clear all, clc, tic
disp([' --- ' mfilename ' --- ']);

addpath([pwd '\..\']);

tableprint([1; 11], [2; 2], {'a'; 'aaa'}, 'VariableNames', ...
  {'a', 'b', 'c'}, 'Format', {'%.2f', []}, 'RowNames', {'b'; 'bb'}, ...
  'Save', 'plain', 'File', 'table-1.txt');

tex1 = tableprint([1; 11], [2; 2], {'aa'; 'bbb'}, ...
  'VariableNames', {'aaaaaaaaaaa', 'b', 'cccccc'}, ...
  'Format', {'%.2f', []}, 'RowNames', {'b'; 'bb'})

tex2 = tableprint([1; 11], [2; 2], {'aa'; 'bbb'}, ...
  'VariableNames', {'aaaaaaaaaaa', 'b', 'cccccc'}, ...
  'Format', {'%.2f', []}, 'RowNames', {'b'; 'bb'}, 'Save', 'tex', ...
  'File', 'table-2.tex')

tex3 = tableprint([1; 11], [2; 2], {'a'; 'aaa'}, 'VariableNames', ...
  {'a', 'b', 'c'}, 'Format', {'%.2f', []}, 'Save', 'tex', ...
  'File', 'table-3.tex')
  
% - End of program
disp(' The program was successfully executed... ');
disp([' Execution time: ' num2str(toc, '%.2f') ' seconds']);
disp(' -------------------- ');