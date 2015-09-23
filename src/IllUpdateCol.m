% function resp = IllUpdateCol(db, user, pwd, col, filename, op, field)
% Apply operation 'op' with field 'field' on document 'filename'. 
%
% 'field' is json, i.e. has the form {<name>:<value>}.
% 'op' includes (but not limited to, see the MongoDb field update operators
% for the complete list): inc, mul, max, min, set, unset.
%
% Long Le
% University of Illinois
% longle1@illinois.edu
%
function resp = IllUpdateCol(db, user, pwd, col, filename, op, field)

params = {'dbname', db, 'colname', col, 'user', user, 'passwd', pwd};
queryString = http_paramsToString(params);
data = sprintf('{filename:"%s"}\n{$%s:%s}', filename, op, field);
resp = urlread2(['https://acoustic.ifp.illinois.edu:8081/write?' queryString], 'POST', data, [], 'READ_TIMEOUT', 10000);
