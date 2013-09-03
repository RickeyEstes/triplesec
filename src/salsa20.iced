#
# Copied from:
# 
#   https://gist.github.com/dchest/4582374
#   http://cr.yp.to/snuffle/salsa20/ref/salsa20.c
#
#   

{WordArray} = require './wordarray'
{Counter} = require './ctr'

#====================================================================

exports.Salsa20 = class Salsa20

  sigma : WordArray.from_buffer_le(new Buffer("expand 32-byte k"), 16)
  tau : WordArray.from_buffer_le(new Buffer("expand 16-byte-k"), 16)

  #--------------

  constructor : (@key, @nonce) ->
    @input = []
    @_fix_key()
    # Constants.
    @rounds = 20   # number of Salsa rounds
    @sigma = new WordArray [0x61707865, 0x3320646e, 0x79622d32, 0x6b206574], 4*4
    @_reset()

  #--------------

  key_setup : () ->
    for i in [0...4]
      @input[i+1] = @key.words[i]
    [C,A] = if @key.sigBytes is 32 then [ Salsa20.sigma, @key.words[4...] ]
    else [ Salsa20.tau, @key.words ]
    for i in [0...4]
      @input[i+11] = A[i]
    for i in [0...4]
      @input[i*5] = C.words[i]

  #--------------

  _fix_key : () ->
    keysize = 32
    b = @key.to_buffer()
    n = b.length
    if n < keysize
      rem = (keysize - n)
      b2 = new Buffer (0x0 for i in [0...rem])
      b3 = Buffer.concat [b, b2]
      console.log b3
      @key = WordArray.from_buffer b3

  _reset : () ->
    @counter = new Counter { len : 2 }
    # Output buffer.
    @block = []        #output block of 64 bytes
    @blockUsed = 64    #number of block bytes used

  # getBytes returns the next numberOfBytes bytes of stream.
  getBytes : (numberOfBytes) ->
    out = new Buffer numberOfBytes
    for i in [0...numberOfBytes]
      if @blockUsed is 64
        @_generateBlock()
        @counter.inc_le()
        @blockUsed = 0
      out.writeUInt8 @block[@blockUsed++], i
    out

  # _generateBlock generates 64 bytes from key, nonce, and counter,
  # and puts the result into this.block.
  _generateBlock : ->
    x0  = @input[0]
    x1  = @input[1]
    x2  = @input[2]
    x3  = @input[3]
    x4  = @input[4]
    x5  = @input[5]
    x6  = @input[6]
    x7  = @input[7]
    x8  = @input[8]
    x9  = @input[9]
    x10 = @input[10]
    x11 = @input[11]
    x12 = @input[12]
    x13 = @input[13]
    x14 = @input[14]
    x15 = @input[15]

    for i in [0...@rounds] by 2
      u = x0 + x12;    x4  ^= (u<<7)  | (u>>>(32-7))
      u = x4 + x0;     x8  ^= (u<<9)  | (u>>>(32-9))
      u = x8 + x4;     x12 ^= (u<<13) | (u>>>(32-13))
      u = x12 + x8;    x0  ^= (u<<18) | (u>>>(32-18))
      u = x5 + x1;     x9  ^= (u<<7)  | (u>>>(32-7))
      u = x9 + x5;     x13 ^= (u<<9)  | (u>>>(32-9))
      u = x13 + x9;    x1  ^= (u<<13) | (u>>>(32-13))
      u = x1 + x13;    x5  ^= (u<<18) | (u>>>(32-18))
      u = x10 + x6;    x14 ^= (u<<7)  | (u>>>(32-7))
      u = x14 + x10;   x2  ^= (u<<9)  | (u>>>(32-9))
      u = x2 + x14;    x6  ^= (u<<13) | (u>>>(32-13))
      u = x6 + x2;     x10 ^= (u<<18) | (u>>>(32-18))
      u = x15 + x11;   x3  ^= (u<<7)  | (u>>>(32-7))
      u = x3 + x15;    x7  ^= (u<<9)  | (u>>>(32-9))
      u = x7 + x3;     x11 ^= (u<<13) | (u>>>(32-13))
      u = x11 + x7;    x15 ^= (u<<18) | (u>>>(32-18))
      u = x0 + x3;     x1  ^= (u<<7)  | (u>>>(32-7))
      u = x1 + x0;     x2  ^= (u<<9)  | (u>>>(32-9))
      u = x2 + x1;     x3  ^= (u<<13) | (u>>>(32-13))
      u = x3 + x2;     x0  ^= (u<<18) | (u>>>(32-18))
      u = x5 + x4;     x6  ^= (u<<7)  | (u>>>(32-7))
      u = x6 + x5;     x7  ^= (u<<9)  | (u>>>(32-9))
      u = x7 + x6;     x4  ^= (u<<13) | (u>>>(32-13))
      u = x4 + x7;     x5  ^= (u<<18) | (u>>>(32-18))
      u = x10 + x9;    x11 ^= (u<<7)  | (u>>>(32-7))
      u = x11 + x10;   x8  ^= (u<<9)  | (u>>>(32-9))
      u = x8 + x11;    x9  ^= (u<<13) | (u>>>(32-13))
      u = x9 + x8;     x10 ^= (u<<18) | (u>>>(32-18))
      u = x15 + x14;   x12 ^= (u<<7)  | (u>>>(32-7))
      u = x12 + x15;   x13 ^= (u<<9)  | (u>>>(32-9))
      u = x13 + x12;   x14 ^= (u<<13) | (u>>>(32-13))
      u = x14 + x13;   x15 ^= (u<<18) | (u>>>(32-18))

    x0  += @input[0]
    x1  += @input[1]
    x2  += @input[2]
    x3  += @input[3]
    x4  += @input[4]
    x5  += @input[5]
    x6  += @input[6]
    x7  += @input[7]
    x8  += @input[8]
    x9  += @input[9]
    x10 += @input[10]
    x11 += @input[11]
    x12 += @input[12]
    x13 += @input[13]
    x14 += @input[14]
    x15 += @input[15]

    @block[ 0] = ( x0 >>>  0) & 0xff; @block[ 1] = ( x0 >>>  8) & 0xff;
    @block[ 2] = ( x0 >>> 16) & 0xff; @block[ 3] = ( x0 >>> 24) & 0xff;
    @block[ 4] = ( x1 >>>  0) & 0xff; @block[ 5] = ( x1 >>>  8) & 0xff;
    @block[ 6] = ( x1 >>> 16) & 0xff; @block[ 7] = ( x1 >>> 24) & 0xff;
    @block[ 8] = ( x2 >>>  0) & 0xff; @block[ 9] = ( x2 >>>  8) & 0xff;
    @block[10] = ( x2 >>> 16) & 0xff; @block[11] = ( x2 >>> 24) & 0xff;
    @block[12] = ( x3 >>>  0) & 0xff; @block[13] = ( x3 >>>  8) & 0xff;
    @block[14] = ( x3 >>> 16) & 0xff; @block[15] = ( x3 >>> 24) & 0xff;
    @block[16] = ( x4 >>>  0) & 0xff; @block[17] = ( x4 >>>  8) & 0xff;
    @block[18] = ( x4 >>> 16) & 0xff; @block[19] = ( x4 >>> 24) & 0xff;
    @block[20] = ( x5 >>>  0) & 0xff; @block[21] = ( x5 >>>  8) & 0xff;
    @block[22] = ( x5 >>> 16) & 0xff; @block[23] = ( x5 >>> 24) & 0xff;
    @block[24] = ( x6 >>>  0) & 0xff; @block[25] = ( x6 >>>  8) & 0xff;
    @block[26] = ( x6 >>> 16) & 0xff; @block[27] = ( x6 >>> 24) & 0xff;
    @block[28] = ( x7 >>>  0) & 0xff; @block[29] = ( x7 >>>  8) & 0xff;
    @block[30] = ( x7 >>> 16) & 0xff; @block[31] = ( x7 >>> 24) & 0xff;
    @block[32] = ( x8 >>>  0) & 0xff; @block[33] = ( x8 >>>  8) & 0xff;
    @block[34] = ( x8 >>> 16) & 0xff; @block[35] = ( x8 >>> 24) & 0xff;
    @block[36] = ( x9 >>>  0) & 0xff; @block[37] = ( x9 >>>  8) & 0xff;
    @block[38] = ( x9 >>> 16) & 0xff; @block[39] = ( x9 >>> 24) & 0xff;
    @block[40] = (x10 >>>  0) & 0xff; @block[41] = (x10 >>>  8) & 0xff;
    @block[42] = (x10 >>> 16) & 0xff; @block[43] = (x10 >>> 24) & 0xff;
    @block[44] = (x11 >>>  0) & 0xff; @block[45] = (x11 >>>  8) & 0xff;
    @block[46] = (x11 >>> 16) & 0xff; @block[47] = (x11 >>> 24) & 0xff;
    @block[48] = (x12 >>>  0) & 0xff; @block[49] = (x12 >>>  8) & 0xff;
    @block[50] = (x12 >>> 16) & 0xff; @block[51] = (x12 >>> 24) & 0xff;
    @block[52] = (x13 >>>  0) & 0xff; @block[53] = (x13 >>>  8) & 0xff;
    @block[54] = (x13 >>> 16) & 0xff; @block[55] = (x13 >>> 24) & 0xff;
    @block[56] = (x14 >>>  0) & 0xff; @block[57] = (x14 >>>  8) & 0xff;
    @block[58] = (x14 >>> 16) & 0xff; @block[59] = (x14 >>> 24) & 0xff;
    @block[60] = (x15 >>>  0) & 0xff; @block[61] = (x15 >>>  8) & 0xff;
    @block[62] = (x15 >>> 16) & 0xff; @block[63] = (x15 >>> 24) & 0xff;

#====================================================================
