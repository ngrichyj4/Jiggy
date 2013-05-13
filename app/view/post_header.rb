class PostHeader < UIView
  
def init
     @nib =  NSBundle.mainBundle.loadNibNamed('Jiggy', owner:self, options:nil)[7]
    return @nib
  
end

#def dealloc
#  puts "Dealloc"
#end
	
end