function text=sec2text(t)
hour=floor(t/3600);
t=rem(t,3600);
min=floor(t/60);
t=rem(t,60);
sec=floor(t);

text=sprintf('%02u:%02u:%02u',hour,min,sec);
end

