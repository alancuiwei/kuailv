# encoding : utf-8

createtime = Time.now

txt = File.open("time.txt","a")
txt.puts(createtime)
txt.close