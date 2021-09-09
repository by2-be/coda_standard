module CodaStandard
  class Transaction
    attr_accessor :name, :currency, :bic, :address, :amount, :account,
      :entry_date, :reference_number, :structured_communication, :detail_number,
      :client_reference

    def match_structured_communication(structured_communication)
      @structured_communication == structured_communication
    end

    def amount_cents
      (@amount.to_f * 100).to_i
    end

    def amount_money
      "#{amount_cents.to_s.insert(-3, ",")} #{@currency}"
    end
  end
end
