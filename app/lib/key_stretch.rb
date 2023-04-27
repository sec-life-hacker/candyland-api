# frozen_string_literal: true

require 'base64'
require 'rbnacl'

# Hashing password with key-stretching hashing method
module KeyStretch
  def new_salt
    RbNaCl::Random.random_bytes(RbNaCl::PasswordHash::SCrypt::SALTBYTES)
  end

  def password_hash(salt, password)
    opslimit = 2**20
    memlimit = 2**24
    digest_size = 64

    RbNaCl::PasswordHash.scrypt(
      password, salt,
      opslimit, memlimit, digest_size
    )
  end
end
