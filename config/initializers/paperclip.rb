Paperclip::Attachment.class_eval {
  @default_options = self.default_options.merge({
    :url => "/data/:class/:attachment/:hash_prefix/:id-:hash",
    :hash_data => ":class/:attachment/:id/:filename/:style",
    :hash_secret => "f0964fbe7d1620e24af07cf75753eda8"
  })
}

Paperclip.interpolates :hash_prefix do |attachment, style|
  attachment.hash_key(style)[0,2]
end
