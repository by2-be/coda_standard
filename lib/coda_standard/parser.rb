module CodaStandard
  class Parser
    attr_reader :transactions, :old_balance, :new_balance, :current_bic, :current_account, :current_transaction, :current_transaction_list, :date_new_balance

    def initialize(filename)
      @filename = filename
      @transactions = []
      @current_transaction_list = TransactionList.new
      @current_transaction = Transaction.new
    end

    def valid?
      File.open(@filename, encoding: "ISO-8859-1").each do |line|
        record = Record.new(line)
        return false unless record.valid?
      end
      true
    end

    def parse(skip_validation: skip_validation = false)
      return [] if !skip_validation && !valid?
      File.open(@filename, encoding: "ISO-8859-1").each do |line|
        record = Record.new(line)
        case
        when record.header?
          create_transaction_list
          @current_transaction_list.current_bic = record.current_bic
        when record.data_old_balance?
          set_account(record.current_account)
          @current_transaction_list.old_balance = record.old_balance
        when record.data_new_balance?
          set_date_new_balance(record)
          @current_transaction_list.new_balance = record.new_balance
        when record.data_movement1?
          create_transaction
          extract_data_movement1(record)
        when record.data_movement2?
          extract_data_movement2(record)
        when record.data_movement3?
          extract_data_movement3(record)
        when record.data_information2?
          set_address(record.address)
        end
      end
      @transactions
    end

    def set_address(address)
      @current_transaction.address = address
    end

    def set_account(account)
      @current_transaction_list.current_account = account[:account_number]
      @current_transaction_list.current_account_type = account[:account_type]
    end

    def create_transaction
      @current_transaction = @current_transaction_list.create_transaction
    end

    def create_transaction_list
      @current_transaction_list = TransactionList.new
      @transactions << @current_transaction_list
    end

    def set_date_new_balance(record)
      @current_transaction_list.date_new_balance = Date.strptime(record.date_new_balance, "%d%m%y")
    end

    def extract_data_movement1(record)
      @current_transaction.entry_date = Date.strptime(record.entry_date, "%d%m%y")
      @current_transaction.reference_number = record.reference_number
      @current_transaction.detail_number = record.detail_number
      @current_transaction.amount = record.amount
      @current_transaction.structured_communication = record.structured_communication
    end

    def extract_data_movement2(record)
      @current_transaction.bic = record.bic
      @current_transaction.client_reference = record.client_reference
    end

    def extract_data_movement3(record)
      @current_transaction.currency = record.currency
      @current_transaction.name = record.name
      @current_transaction.account = record.account
    end

    def show(skip_validation: skip_validation = false)
      puts "The file is invalid" if !skip_validation && !valid?
      parse(skip_validation: skip_validation)
      @transactions.each_with_index do |transaction, index|
        puts "**--Transaction List #{index + 1}--**\n\n"
        puts "Account: #{transaction.current_account} Account type: #{transaction.current_account_type} BIC: #{transaction.current_bic}"
        puts "Old balance: #{transaction.old_balance} \nNew balance: #{transaction.new_balance} \n\n"
        transaction.each_with_index do |transaction, index|
          puts "-- Transaction n.#{index + 1} - number #{transaction.structured_communication} - in date #{transaction.entry_date}-- \n\n"
          puts "   RN: #{transaction.reference_number} Account: #{transaction.account} BIC: #{transaction.bic}"
          puts "   Amount: #{transaction.amount_money}"
          puts "   Name: #{transaction.name}"
          puts "   Address: #{transaction.address} \n\n"
        end
      end
    end
  end
end
