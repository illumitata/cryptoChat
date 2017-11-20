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
    # Don't go to next step if file is empty
    return if stringText==""
    # Unpack the binary string
    stringText = stringText.unpack("B*")[0]
    # Scan the history to 64 bits blocks = 8 chars
    stringText = stringText.scan(/.{1,64}/)
    # Decrypt whole convo-story
    textHistory = CipherMessage::decode(stringText)
    # Refresh the box with current history
    box.setText(textHistory)
  end

  def sendTextBox(box, adres)
    # Delete the \n to fix in future
    sendMessage = box.toPlainText.chomp
    # Send text to encryption method
    sendMessage = CipherMessage::init(sendMessage)
    # Join the array to string
    sendMessage = sendMessage.join
    # Fix it to string without SPACE char
    sendMessage.gsub!(" ", '')
    # Pack it into binary and append the history file
    File.open(adres,'ab+') do |output|
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
  @key = '01101010 01101010 01101010 01101010 01101010 01101010 01101010 01101010
          01101010 01101010 01101010 01101010 01101010 01101010 01101010 01101010'
  def init(text)
    # Map text into 8 char blocks
    text = mapText(text)
    # Encrypt given text
    cipherMessage = []
    text.each do |block|
      message1 = Encryption.new(block, @key)
      x1 = message1.tripledes_encrypt
      cipherMessage << x1.blocks(8)#.to_text
    end
    cipherMessage
  end

  def mapText(text)
    text = text.scan(/.{1,8}/)
    # Fix sizes of blocks with less than 8 chars
    text.each do |block|
      if block.size < 8
        (8-block.size).times do
          # Add chars to satisfy 8char block
          block << " " # "*"
        end
      end
    end
    text
  end

  def decode(sText)
    decryptMessage = ""
    sText.each do |block|
      message2 = Encryption.new(block.to_bits, @key)
      x2 = message2.tripledes_decrypt
      # Convert from 1010 string to ASCII string form
      x2 = x2.blocks(8).to_text
      # Fix the text to readable form
      x2.gsub!(" ", "")#.gsub!("*", "")
      # Add the decrypted block to final message
      decryptMessage << x2
    end
    decryptMessage
  end

  module_function :init, :mapText, :decode
end
