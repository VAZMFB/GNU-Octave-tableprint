function varargout = tableprint(varargin)
% Print data in form of table with headers
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
% ----- INPUTS -----
% varargin - data for table cells and options
% ----- OUTPUTS -----
% varargout - string for table in TeX format
% --------------------

% Parse function options
options = {};
opt_pos = nargin+1;
p = inputParser;
addParameter(p, 'VariableNames', {}, ...
  @(x) (iscell(x) && all(cellfun('ischar', x))) || ischar(x));
addParameter(p, 'RowNames', {}, ...
  @(x) (iscell(x) && all(cellfun('ischar', x))) || ischar(x));
addParameter(p, 'Format', {});
addParameter(p, 'Save', 'no', ...
  @(x) ischar(x) && (strcmpi(x, 'no') || strcmpi(x, 'plain') ...
    || strcmpi(x, 'tex')));
addParameter(p, 'File', 'table.tex', @(x) ischar(x));
addParameter(p, 'BrakeLine', 'no', ...
  @(x) ischar(x) && (strcmpi(x, 'no') || strcmpi(x, 'yes')));
addParameter(p, 'rlines', 'yes', ...
  @(x) ischar(x) && (strcmpi(x, 'no') || strcmpi(x, 'yes')));
addParameter(p, 'clines', 'yes', ...
  @(x) ischar(x) && (strcmpi(x, 'no') || strcmpi(x, 'yes')));
addParameter(p, 'align', 'c', ...
  @(x) (iscell(x) && all(cellfun('ischar', x))) || ischar(x));
addParameter(p, 'float', 'H', @(x) ischar(x));
addParameter(p, 'caption', 'Table 1', @(x) ischar(x));
addParameter(p, 'label', 'tabel-1', @(x) ischar(x));
  
if(~isempty(varargin) && iscell(varargin) && nargin > 1)
  is_option = cellfun(@(x) ischar(x) &&...
    any(strcmpi(x, p.Parameters)), varargin);
  if(any(is_option))
    opt_pos = find(is_option)(1);
    N_opt = nargin-opt_pos+1;
    if(N_opt > 0 && (rem(N_opt, 2) == 0))
      options = {varargin{opt_pos:nargin}};
    else
      error('Invalid parameter/value pair arguments.');
    end
  end
end
p.parse(options{:});

VariableNames = p.Results.VariableNames;
RowNames = p.Results.RowNames;
Format = p.Results.Format;
Save = p.Results.Save;
File = p.Results.File;
BrakeLine = p.Results.BrakeLine;
rlines = p.Results.rlines;
clines = p.Results.clines;
align = p.Results.align;
float = p.Results.float;
caption = p.Results.caption;
label = p.Results.label;

% Print string function
if(~strcmpi(Save, 'no'))
  fid = fopen(File, 'w');
end

if(strcmpi(Save, 'plain'))
  strprint = @(varargin) {fprintf(varargin{:}); fprintf(fid, varargin{:})}; 
elseif(strcmpi(Save, 'no'))
  strprint = @(varargin) fprintf(varargin{:}); 
else
  strprint = @(varargin) fprintf(fid, varargin{:}); 
end

% Number of table columns and rows
N_col = opt_pos-1;
if(N_col <= 0)
  error('No available table data.');
end
data_rows  = cellfun(@(x) size(x, 1), varargin(1:N_col));
data_col = cellfun(@(x) size(x, 2), varargin(1:N_col));
if(~all(data_rows == data_rows(1)))
  error('Different number of rows.');
end
if(any(data_col ~= 1))
  error('Multicolumn data not yet supported.');
end
N_rows = data_rows(1);

% VariableNames
if(~isempty(VariableNames))
  if(length(VariableNames) ~= N_col)
    error('Number of variable names not equal to number of columns.');
  end
else
  for i = 1:N_col
    if(isempty(inputname(i)))
      error('Variable name for column %i is not available.', i);
    end
    VariableNames{i} = sprintf('%s', inputname(i));
  end
end
vn_width  = cellfun(@(x) length(x), VariableNames);

% RowNames
if(~isempty(RowNames))
  if(length(RowNames) ~= N_rows)
    error('Number of row names not equal to number of rows.');
  end
  rn_tab = 1;
else
  RowNames = cell(1, N_rows);
  rn_tab = 0;
end
rn_width  = cellfun(@(x) length(x), RowNames);
max_rn_width = max(rn_width);

% Prepere every cell
cells = cell(N_rows, N_col);
cell_width = zeros(N_rows, N_col);
cell_type = zeros(N_rows, N_col);
for j = 1:N_col
  if(~isempty(Format) && length(Format) >= j && ~isempty(Format{j}))
    if(iscell(varargin{j}))
      for i = 1:N_rows 
        cells{i, j} = sprintf(Format{j}, varargin{j}{i});
        if(~ischar(varargin{j}{i}) && ~islogical(varargin{j}{i}))
          cell_type(i, j) = 1;
        end
      end
    else
      for i = 1:N_rows 
        cells{i, j} = sprintf(Format{j}, varargin{j}(i));
        if(~islogical(varargin{j}(i)))
          cell_type(i, j) = 1;
        end
      end
    end
  else
    if(iscell(varargin{j}))
      for i = 1:N_rows 
        if(ischar(varargin{j}{i}))
          cells{i, j} = sprintf('%s', varargin{j}{i});
        elseif(isinteger(varargin{j}(i)))
          cells{i, j} = sprintf('%i', varargin{j}{i});
          cell_type(i, j) = 1;
        elseif(islogical(varargin{j}{i}))
          if(varargin{j}{i} == 1)
            cells{i, j} = 'true';
          else
            cells{i, j} = 'false';
          end
        else
          cells{i, j} = sprintf('%f', varargin{j}{i});
          cell_type(i, j) = 1;
        end
      end
    elseif(isinteger(varargin{j}))
      for i = 1:N_rows 
        cells{i, j} = sprintf('%i', varargin{j}(i));
        cell_type(i, j) = 1;
      end
    elseif(islogical(varargin{j}))
      for i = 1:N_rows 
        if(varargin{j}(i) == 1)
          cells{i, j} = 'true';
        else
          cells{i, j} = 'false';
        end
      end
    else 
      for i = 1:N_rows 
        cells{i, j} = sprintf('%f', varargin{j}(i));
        cell_type(i, j) = 1;
      end
    end
  end
end

for j = 1:N_col
  for i = 1:N_rows
    cell_width(i, j) = length(cells{i, j});
  end
end
col_data_width = max(cell_width);
col_width = max([col_data_width; vn_width]);

% Check terminal width
twh = terminal_size();
if(strcmpi(BrakeLine, 'yes'))
  error('Break line is not yet supported.');
else
  N_breaks = 0;
end

% Print table header (variable names)
% strprint('%ix%i table\n', N_rows, N_col)
strprint('\n%s', repmat(' ', 1, max_rn_width+rn_tab*4));
suf = 0;
for j = 1:N_col
  pref = floor((col_width(j)-vn_width(j))/2);
  strprint('%s%s', repmat(' ', 1, suf+4+pref), VariableNames{j});
  suf = col_width(j)-vn_width(j)-pref;
end
strprint('\n%s', repmat(' ', 1, max_rn_width+rn_tab*4));
for j = 1:N_col
  strprint('%s%s', repmat(' ', 1, 4), repmat('_', 1, col_width(j)));
end
strprint('\n\n');

% Print rows (RowNames and cells)
for i = 1:N_rows
  strprint('%s%s%s', repmat(' ', 1, rn_tab*4), RowNames{i}, ...
    repmat(' ', 1, max_rn_width-rn_width(i)));
  suf = 0;
  for j = 1:N_col
    pref = floor((col_width(j)-col_data_width(j))/2);
    if(cell_type(i, j))
      strprint('%s%s', repmat(' ', 1, ...
        suf+4+pref+(col_data_width(j)-cell_width(i, j))), cells{i, j});
      suf = col_width(j)-col_data_width(j)-pref;
    else
      strprint('%s%s', repmat(' ', 1, suf+4+pref), cells{i, j});
      suf = col_width(j)-cell_width(i, j)-pref;
    end
  end
  strprint('\n');
end
strprint('\n');

% Close file
if(~strcmpi(Save, 'no'))
  fclose(fid);
end

% Return TeX
if(length(nargout) == 1 || strcmpi(Save, 'tex'))
  % Check row lines option
  if(strcmpi(rlines, 'yes'))
    rl = '\hline';
  else
    rl = '';
  end
  
  % Check column lines option
  if(strcmpi(clines, 'yes'))
    cl = '|';
  else
    cl = '';
  end
  
  % Check align option
  if(iscell(align) && length(align) ~= N_col)
    error('Number of align specifiers not equal to number of columns');
  elseif(ischar(align)) 
    al = repelem({align}, N_col);
  else
    al = align;
  end

  % Table header
  tex = ["\n" '\begin{table}[' float ']' "\n" ...
    '  \centering' "\n" ...
    '  \captionof{table}{' caption '}' "\n" ...
    '  \label{' label  '}' "\n" ...
    '  \begin{tabular}[H]{'];
  if(rn_tab)
    tex = [tex cl 'l' cl];
  end
  tex = [tex sprintf([cl '%s'], al{:}) cl '}' "\n"];

  % Variable names
  tex = [tex '    ' rl "\n" '    '];
  for j = 1:N_col
    if(j == 1 && ~rn_tab)
      tex = [tex sprintf('\\textbf{%s}', VariableNames{j})];
    else
      tex = [tex sprintf(' & \\textbf{%s}', VariableNames{j})];
    end
  end
  tex = [tex ' \\ \hline' "\n"];

  % Table rows (RowNames and cells)
  for i = 1:N_rows
    if(~isempty(RowNames{i})) 
      tex = [tex sprintf('    \\textbf{%s}', RowNames{i})];
    else
      tex = [tex '    '];
    end
    suf = 0;
    for j = 1:N_col
      if(j == 1 && ~rn_tab)
        tex = [tex sprintf('%s', cells{i, j})];
      else
        tex = [tex sprintf(' & %s', cells{i, j})];
      end
    end
    tex = [tex ' \\ ' rl "\n"];
  end
  
  % Table footer
  tex = [tex ' \end{tabular}' "\n" ...
    '\end{table}' "\n"];
    
  % Save to file
  if(strcmpi(Save, 'tex'))
    fid = fopen(File, 'w');
    fputs(fid, tex);
    fclose(fid);
  end
  
  % Return string
  if(length(nargout) == 1)
    varargout{1} = tex;
  end
end
end