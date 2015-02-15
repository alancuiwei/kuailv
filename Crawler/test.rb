# encoding : utf-8

createtime = Time.now

txt = File.open("time.txt","w+")
txt.puts(createtime)
txt.close