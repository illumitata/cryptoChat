##############
# message.rb #
##############
# Require the encryption.rb file for de/encrypt text
require './encryption'
require './key'

# Patch for String class
class String
  # Switch end lines
   def changeEndLines
     self.gsub("\n", '\n')
   end

   #Recovers end lines from decrypted message
    def recoverEndLines
      self.gsub('\n', "\n")
    end
end

# Message module responsible for coresponding with files, database
module Message
  ####################################################
  # To delete later, replace with database ~ Patryk
  def checkIfFileExist
    # Search for file in folder
    if File.exist?('message') == false
      # Make file if there isn't one
      file = File.open('message', 'wb+')
      file.close
    end
  end
  ####################################################

  def refreshTextBox(box)
    # Open file in binary mode
    stringText = File.binread('message')
    # Don't go to next step if file is empty
    return if stringText == ''
    # Unpack the binary string
    stringText = stringText.unpack('B*')[0]
    # Scan the history to 64 bits blocks = 8 chars
    stringText = stringText.scan(/.{1,64}/)
    # Decrypt whole convo-story
    textHistory = CipherMessage::decode(stringText).recoverEndLines
    # Refresh the box with current history
    box.setText(textHistory)
  end

  def sendTextBox(box, adres)
    # Convert end lines "\n" and add extra one at the end
    sendMessage = box.toPlainText.changeEndLines
    sendMessage << '\n'
    # Send text to encryption method
    sendMessage = CipherMessage::init(sendMessage)
    # Join the array to string
    sendMessage = sendMessage.join
    # Fix it to string without SPACE char
    sendMessage.delete!(' ') # you can use .gsub(" ", "")
    # Pack it into binary and append the history file
    File.open(adres, 'ab+') do |output|
      output.write [sendMessage].pack('B*')
    end
    box.clear
  end

  def deleteContent(adres)
    file = File.open(adres, 'ab+')
    file.truncate(0)
    file.close
  end

  module_function :refreshTextBox, :sendTextBox, :deleteContent, :checkIfFileExist
end

# Module for message transform
module CipherMessage
#  @key = GenerateKey::genkey
  @key = '01101010 01101010 01101010 01101010 01101010 01101010 01101010 01101010
          01101010 01101010 01101010 01101010 01101010 01101010 01101010 01101010'
  # Initialize Encryption method for input
  def init(text)
    # Map text into 8 char blocks
    text = mapText(text)
    # Encrypt given text
    cipherMessage = []
    text.each do |block|
      message1 = Encryption.new(block, @key)
      x1 = message1.tripledes_encrypt
      cipherMessage << x1.blocks(8) # .to_text
    end
    cipherMessage
  end

  # Mapping text into 8 chars blocks
  def mapText(text)
    text = text.scan(/.{1,8}/)
    # Fix sizes of blocks with less than 8 chars
    text.each do |block|
      if block.size < 8
        (8-block.size).times do
          # Add chars to satisfy 8char block
          block << " " # DO NOT EDIT " "
        end
      end
    end
    text
  end

  # Decode history of conversation
  def decode(sText)
    decryptMessage = ''
    sText.each do |block|
      message2 = Encryption.new(block.to_bits, @key)
      x2 = message2.tripledes_decrypt
      # Convert from 1010 string to ASCII string form
      x2 = x2.blocks(8).to_text
      # Fix the text to readable form
      x2.delete!(" ") # .gsub!(" ", "") # DO NOT EDIT " "
      # Add the decrypted block to final message
      decryptMessage << x2
    end
    decryptMessage
  end

  module_function :init, :mapText, :decode
end
