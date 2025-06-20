require_relative "spec_helper"

describe CodaStandard::Record do
  let(:header_record) { CodaStandard::Record.new("0000031031520005                  MMIF SA/BANK              GEBABEBB   00538839354 00000                                       2") }
  let(:old_balance_data_record) { CodaStandard::Record.new("10016539007547034 eur0be                  0000000057900000300315mmif sa/evocure                                              017") }
  let(:old_balance_data_record_invalid) { CodaStandard::Record.new("100/0000/00135") }
  let(:data_movement1_record) { CodaStandard::Record.new("21000100000001500000103        0000000000500860010415001500001101100000834941                                      31031501601 0") }
  let(:data_movement1b_record) { CodaStandard::Record.new("21000100000001500000103        1000000000500860010415001500000UNSTRUCTURED COMMUNICATION MESSAGE                                      31031501601 0") }
  let(:data_movement2_record) { CodaStandard::Record.new("2200010000                                                                                        GKCCBEBB                   1 0") }
  let(:data_movement2b_record) { CodaStandard::Record.new("2200040011/60                                                  client reference ABCDEFGHIJKLMN    GKCCBEBB                   1 0") }
  let(:data_movement3_record) { CodaStandard::Record.new("2300010000BE53900754703405                  EURLASTNM PERSON                                                                 0 1") }
  let(:data_detail_record) { CodaStandard::Record.new("21000100010001500000103        0000000000500860010415001500001101100000834941                                      31031501601 0") }
  let(:data_information2_record) { CodaStandard::Record.new("32000200015 STREET                                     3654 CITY BELGIQUE                                                    0 0") }
  let(:data_information2b_record) { CodaStandard::Record.new("32000200015 STREET                                     3654    CITY BELGIQUE                                                    0 0") }
  let(:data_information2c_record) { CodaStandard::Record.new("32000200015 STREET                                     3654    ST CITY BELGIQUE                                                  0 0") }
  let(:new_balance_data_record) { CodaStandard::Record.new("8016035918134040 EUR0BE                  0000000058900000140122                                                                0") }
  let(:new_balance_data_record_not_present) { CodaStandard::Record.new("8001BE28097913160020                  EUR0000000000000000000000                                                                0") }
  let(:new_balance_data_record_negative) { CodaStandard::Record.new("8016035918134040 EUR0BE                  1000000058900000140122                                                                0") }

  describe "data_header" do
    it "returns true if the line starts with a zero" do
      expect(header_record.header?).to be true
    end

    it "returns false if the line does not start with a zero" do
      expect(old_balance_data_record.header?).to be false
    end
  end

  describe "data_new_balance" do
    it "returns true if the line starts with a eight" do
      expect(new_balance_data_record.data_new_balance?).to be true
    end
  end

  describe "data_old_balance" do
    it "returns true if the line starts with a one" do
      expect(old_balance_data_record.data_old_balance?).to be true
    end

    it "returns false if the line does not start with a one" do
      expect(header_record.data_old_balance?).to be false
    end
  end

  describe "data_movement1" do
    it "returns true if the line starts with a 21" do
      expect(data_movement1_record.data_movement1?).to be true
    end

    it "returns false if the line does not start with 21" do
      expect(header_record.data_movement1?).to be false
    end
  end

  describe "data_detail" do
    it "returns the detail number if detail record" do
      expect(data_detail_record.detail_number).to eq 1
    end

    it "returns nil if no detail record" do
      expect(data_movement1_record.detail_number).to be_nil
    end
  end

  describe "data_movement2" do
    it "returns true if the line starts with a 22" do
      expect(data_movement2_record.data_movement2?).to be true
    end

    it "returns false if the line does not start with 22" do
      expect(header_record.data_movement2?).to be false
    end
  end

  describe "data_movement3" do
    it "returns true if the line starts with a 23" do
      expect(data_movement3_record.data_movement3?).to be true
    end

    it "returns false if the line does not start with 23" do
      expect(header_record.data_movement3?).to be false
    end
  end

  describe "data_information2" do
    it "returns true if the line starts with a 32" do
      expect(data_information2_record.data_information2?).to be true
    end

    it "returns false if the line does not start with 32" do
      expect(header_record.data_information2?).to be false
    end
  end

  describe "current_bic" do
    it "extracts the current_bic" do
      expect(header_record.current_bic).to eq("GEBABEBB")
    end
  end

  describe "current_account" do
    it "extracts the current_account" do
      expect(old_balance_data_record.current_account).to eq({ account_number: "539007547034", account_type: "bban_be_account" })
    end
  end

  describe "old_balance" do
    it "extracts the old_balance" do
      expect(old_balance_data_record.old_balance).to eq("57900.000")
    end

    it "returns nil if no new balance is present" do
      expect(new_balance_data_record_not_present.old_balance).to be_nil
    end
  end

  describe "new_balance" do
    it "extracts the new_balance" do
      expect(new_balance_data_record.new_balance).to eq("58900.000")
    end

    it "extracts negative values" do
      expect(new_balance_data_record_negative.new_balance).to eq("-58900.000")
    end

    it "returns nil if no new balance is present" do
      expect(new_balance_data_record_not_present.new_balance).to be_nil
    end
  end

  describe "date_new_balance" do
    it "extracts the date new balance" do
      expect(new_balance_data_record.date_new_balance).to eq("140122")
    end

    it "returns nil if no new balance is present" do
      expect(new_balance_data_record_not_present.date_new_balance).to be_nil
    end
  end

  describe "entry_date" do
    it "extracts the entry_date" do
      expect(data_movement1_record.entry_date).to eq("310315")
    end
  end

  describe "reference_number" do
    it "extracts the reference_number" do
      expect(data_movement1_record.reference_number).to eq("0001500000103")
    end
  end

  describe "amount" do
    it "extracts the credit amount" do
      expect(data_movement1_record.amount).to eq("500.860")
    end

    it "extracts the debet amount" do
      expect(data_movement1b_record.amount).to eq("-500.860")
    end
  end

  describe "bic" do
    it "extracts the bic" do
      expect(data_movement2_record.bic).to eq("GKCCBEBB")
    end
  end

  describe "client_reference" do
    it "extracts the client_reference" do
      expect(data_movement2b_record.client_reference).to eq("client reference ABCDEFGHIJKLMN")
    end
  end

  describe "currency" do
    it "extracts the currency" do
      expect(data_movement3_record.currency).to eq("EUR")
    end
  end

  describe "name" do
    it "extracts the name" do
      expect(data_movement3_record.name).to eq("LASTNM PERSON")
    end
  end

  describe "account" do
    it "extracts the account" do
      expect(data_movement3_record.account).to eq("BE53900754703405")
    end
  end

  describe "structured_communication" do
    context "structured_number" do
      it "extracts the number" do
        expect(data_movement1_record.structured_communication).to eq("100000834941")
      end
    end

    context "non-structured_number" do
      it "returns not structured" do
        expect(data_movement1b_record.structured_communication).to eq("UNSTRUCTURED COMMUNICATION MESSAGE")
      end
    end
  end

  describe "address" do
    it "extracts the address" do
      expect(data_information2_record.address).to eq("5 STREET 3654 CITY BELGIQUE")
      # expect(data_information2_record.address).to eq({:address=>"5 STREET", :postcode=>"3654", :city=>"CITY", :country=>" BELGIQUE"})
      # expect(data_information2b_record.address).to eq({:address=>"5 STREET", :postcode=>"3654", :city=>"CITY", :country=>" BELGIQUE"})
      # expect(data_information2c_record.address).to eq({:address=>"5 STREET", :postcode=>"3654", :city=>"ST CITY", :country=>" BELGIQUE"})
    end
  end

  describe "valid?" do
    it "returns true if the record is valid" do
      expect(old_balance_data_record.valid?).to be true
    end

    it "returns false if the record is invalid" do
      expect(old_balance_data_record_invalid.valid?).to be false
    end
  end
end
