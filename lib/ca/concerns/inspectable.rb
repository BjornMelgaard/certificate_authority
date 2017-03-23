module Inspectable
  def inspect
    <<~HEREDOC
      Certificate: role=#{role},
                   subject=#{subject},
                   issuer=#{issuer},
                   private_key #{'not ' unless @private_key}exists
                   extensions=#{extensions.map(&:to_s)}
    HEREDOC
  end
end
