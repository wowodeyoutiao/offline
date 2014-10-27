a = {}; 
b = {};    
setmetatable(a,b); -- 设置a为weak table 
b.__mode = 'k'; 


a[1] = {} -- weak table引用不增引数，所以"{}"内存块的引数还为1 
a[2] = {}     -- 如上上一样 
a[2] = nil

collectgarbage();   -- 调用GC，清掉weak表中没有引用的内存 
print(#a)
for k,v in pairs(a) do
	print(k,v)
end