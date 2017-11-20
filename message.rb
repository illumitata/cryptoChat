##############
# message.rb #
##############
# Require the encryption.rb file for de/encrypt text
require './encryption'
require './key'

# Message module responsible for coresponding with files, database
module Message
  def refreshTextBox(box)
    stringText = File.binread('message')
    # puts stringText
    return if stringText==""
    stringText = stringText.unpack("B*")[0]
    #puts stringText
    stringText = stringText.scan(/.{1,64}/)
    puts stringText
    textHistory = CipherMessage::decode(stringText)
    # puts textHistory
    box.setText(textHistory)
  end

  def sendTextBox(box, adres)
    sendMessage = box.toPlainText.chomp
    #puts sendMessage.encoding
    sendMessage = CipherMessage::init(sendMessage)
    # puts sendMessage.is_a? Array
    sendMessage = sendMessage.join
    sendMessage.gsub!(" ", '')
    #puts sendMessage
    file = File.open(adres,'ab+') do |output|
      output.write [sendMessage].pack("B*")
    end
    box.clear
  end

  def deleteContent(adres)
    file = File.open(adres, 'ab+')
    file.truncate(0)
    file.close
  end

  module_function :refreshTextBox, :sendTextBox, :deleteContent
end

module GenerateKey
  def genkey
    a = XorshiftGen.new
    key = a.bytes(32).scan(/......../)
    key = key*" "
  return key
  end

  module_function :genkey
end

# Module for message transform
module CipherMessage
#  @key = GenerateKey::genkey
  @key = '01101010 01101010 01101010 01101010 01101010 01101010 01101010 01101010 01101010 01101010 01101010 01101010 01101010 01101010 01101010 01101010'
  def init(text)
    @text = text
    # Map text into 8 char blocks
    mapText
    # Encrypt given text
    cipherMessage = []
    @text.each do |block|
      message1 = Encryption.new(block, @key)
      x1 = message1.tripledes_encrypt
      # puts x1
      # puts x1.blocks(8).to_text
      cipherMessage << x1.blocks(8)#.to_text
    end
    #puts @key
    return cipherMessage
  end

  def mapText
    @text = @text.scan(/.{1,8}/)
    # Fix sizes of blocks with less than 8 chars
    @text.each do |block|
      if block.size < 8
        (8-block.size).times do
          # Add spaces yo make block 8 chars
          block << "*"
          #puts block
        end
      end
    end
  end

  def decode(sText)

    encoding_options = {
    :invalid           => :replace,  # Replace invalid byte sequences
    :undef             => :replace,  # Replace anything not defined in ASCII
    :replace           => '',        # Use a blank for those replacements
    #:universal_newline => true       # Always break lines with \n
    }

    decryptMessage = ""
    sText.each do |block|
      # puts block
      code = block.to_bits
      # puts code
      message2 = Encryption.new(code, @key)
      x2 = message2.tripledes_decrypt
      x2 = x2.blocks(8).to_text#, :invalid => :replace, :replace => ' ')
      x2.gsub!("*", "")
      puts x2.encode(Encoding.find('ASCII'), encoding_options)
      decryptMessage << x2.encode(Encoding.find('UTF-8'), encoding_options)
    end
    return decryptMessage
  end

  module_function :init, :mapText, :decode
end
