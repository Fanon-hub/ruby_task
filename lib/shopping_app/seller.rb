require_relative "user"

class Seller < User
  def initialize(name)
    super(name) # superの役割について確認したい場合は[https://diver.diveintocode.jp/curriculums/2360]のテキストを参考にしてください。
  end

end
