require File.join(File.dirname(__FILE__), 'spec_helper')

describe RDF::List do
  let(:empty) {RDF::List::NIL}
  let(:abc) {RDF::List[RDF::Literal.new('a'), RDF::Literal.new('b'), RDF::Literal.new('c')]}
  let(:ten) {RDF::List[*(1..10)]}

  ORDINALS = %w(first second third fourth fifth sixth seventh eighth ninth tenth)

  it "is comparable" do
    expect(RDF::List.new).to be_a_kind_of(::Comparable)
  end

  it "is enumerable" do
    expect(RDF::List.new).to be_a_kind_of(::Enumerable)
  end

  describe RDF::List, "[] without arguments" do
    it "constructs a new empty list" do
      expect(RDF::List[]).to be_an(RDF::List)
      expect(RDF::List[]).to be_empty
      expect(RDF::List[]).to eq RDF::List::NIL
    end
  end

  describe RDF::List, "[] with arguments" do
    it "constructs a new non-empty list" do
      expect(RDF::List[1, 2, 3]).to be_an(RDF::List)
      expect(RDF::List[1, 2, 3]).not_to be_empty
    end

    it "accepts list arguments" do
      expect { RDF::List[RDF::List[]] }.not_to raise_error
    end

    it "accepts array arguments" do
      expect { RDF::List[[1]] }.not_to raise_error
      l1 = RDF::List[[1]]
      expect(l1.size).to eq 1
      expect(l1.first).to be_a(RDF::Node)
      expect { RDF::List.new(l1.first, l1.graph) }.not_to raise_error
      l2 = RDF::List.new(l1.first, l1.graph)
      expect(l2.first).to eq RDF::Literal(1)
    end

    it "accepts blank node arguments" do
      expect { RDF::List[RDF::Node.new] }.not_to raise_error
    end

    it "accepts URI arguments" do
      expect { RDF::List[RDF.nil] }.not_to raise_error
    end

    it "accepts nil arguments" do
      expect { RDF::List[nil] }.not_to raise_error
    end

    it "accepts literal arguments" do
      expect { RDF::List[RDF::Literal.new("Hello, world!", :language => :en)] }.not_to raise_error
    end

    it "accepts boolean arguments" do
      expect { RDF::List[true, false] }.not_to raise_error
    end

    it "accepts string arguments" do
      expect { RDF::List["foo", "bar"] }.not_to raise_error
    end

    it "accepts integer arguments" do
      expect { RDF::List[1, 2, 3] }.not_to raise_error
    end

    it "accepts float arguments" do
      expect { RDF::List[3.1415] }.not_to raise_error
    end

    it "accepts decimal arguments" do
      expect { RDF::List[BigDecimal("3.1415")] }.not_to raise_error
    end

    it "accepts time arguments" do
      expect { RDF::List[Time.now] }.not_to raise_error
    end

    it "accepts date arguments" do
      expect { RDF::List[Date.new(2010)] }.not_to raise_error
    end

    it "accepts datetime arguments" do
      expect { RDF::List[DateTime.new(2010)] }.not_to raise_error
    end
  end

  describe RDF::List, "#subject" do
    it "requires no arguments" do
      expect { empty.subject }.not_to raise_error
    end

    it "returns a resource" do
      expect(empty.subject).to be_a_resource
    end
  end

  describe RDF::List, "#graph" do
    it "requires no arguments" do
      expect { empty.graph }.not_to raise_error
    end

    it "returns a graph" do
      expect(empty.graph).to be_a_graph
    end
  end

  describe RDF::List, "#&" do
    it "accepts one argument" do
      expect { empty & empty }.not_to raise_error
    end

    it "rejects fewer arguments" do
      expect { empty.__send__(:&) }.to raise_error(ArgumentError)
    end

    it "returns the set intersection of self and the given argument" do
      expect(RDF::List[1, 2] & RDF::List[1, 2]).to eq RDF::List[1, 2]
      expect(RDF::List[1, 2] & RDF::List[2, 3]).to eq RDF::List[2]
      expect(RDF::List[1, 2] & RDF::List[3, 4]).to eq RDF::List[]
    end
  end

  describe RDF::List, "#|" do
    it "accepts one argument" do
      expect { empty | empty }.not_to raise_error
    end

    it "rejects fewer arguments" do
      expect { empty.__send__(:|) }.to raise_error(ArgumentError)
    end

    it "returns the set union of self and the given argument" do
      expect(RDF::List[1, 2] | RDF::List[1, 2]).to eq RDF::List[1, 2]
      expect(RDF::List[1, 2] | RDF::List[2, 3]).to eq RDF::List[1, 2, 3]
      expect(RDF::List[1, 2] | RDF::List[3, 4]).to eq RDF::List[1, 2, 3, 4]
    end
  end

  describe RDF::List, "#+" do
    it "accepts one argument" do
      expect { empty + empty }.not_to raise_error
    end

    it "rejects fewer arguments" do
      expect { empty.__send__(:+) }.to raise_error(ArgumentError)
    end

    it "returns the concatenation of self and the given argument" do
      expect(RDF::List[1, 2] + RDF::List[3, 4]).to eq RDF::List[1, 2, 3, 4]
    end
  end

  describe RDF::List, "#-" do
    it "accepts one argument" do
      expect { RDF::List::NIL - empty }.not_to raise_error
    end

    it "rejects fewer arguments" do
      expect { empty.__send__(:-) }.to raise_error(ArgumentError)
    end

    it "returns the difference between self and the given argument" do
      expect(RDF::List[1, 2, 2, 3] - RDF::List[2]).to eq RDF::List[1, 3]
    end
  end

  describe RDF::List, "#*" do
    it "accepts one argument" do
      expect { empty * 1 }.not_to raise_error
    end

    it "rejects fewer arguments" do
      expect { empty.__send__(:*) }.to raise_error(ArgumentError)
    end
  end

  describe RDF::List, "#* with an integer argument" do
    it "returns a repetition of self" do
      expect(RDF::List[1, 2, 3] * 2).to eq RDF::List[1, 2, 3, 1, 2, 3]
    end
  end

  describe RDF::List, "#* with a string argument" do
    it "returns the string concatenation of all elements" do
      expect(RDF::List[1, 2, 3] * ",").to eq "1,2,3"
    end
  end

  describe RDF::List, "#[]" do
    it "accepts one argument" do
      expect { empty[0] }.not_to raise_error
    end

    it "rejects fewer arguments" do
      expect { empty.__send__(:[]) }.to raise_error(ArgumentError)
    end

    it "returns a value for valid indexes" do
      expect(ten[0]).to be_a_value
    end

    it "returns nil for invalid indexes" do
      expect(empty[0]).to be_nil
      expect(ten[20]).to be_nil
    end
  end

  describe RDF::List, "#[]=" do
    it "needs work"
  end

  describe RDF::List, "#<<" do
    it "accepts one argument" do
      expect { ten << 11 }.not_to raise_error
    end

    it "rejects fewer arguments" do
      expect { ten.__send__(:<<) }.to raise_error(ArgumentError)
    end

    it "appends the new value at the tail of the list" do
      ten << 11
      expect(ten.last).to eq RDF::Literal.new(11)
    end

    it "increments the length of the list by one" do
      ten << 11
      expect(ten.length).to eq 11
    end

    it "returns self" do
      expect(ten << 11).to equal(ten)
    end
  end

  describe RDF::List, "#shift" do
    it "returns the first element from the list" do
      expect(ten.shift).to eq RDF::Literal.new(1)
    end

    it "removes the first element from the list" do
      ten.shift
      expect(ten).to eq RDF::List[2, 3, 4, 5, 6, 7, 8, 9, 10]
    end

    it "should return nil from an empty list" do
      expect(empty.shift).to be_nil
    end
  end

  describe RDF::List, "#unshift" do
    it "adds element to beginning of list" do
      ten.unshift(0)
      expect(ten).to eq RDF::List[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    end

    it "should return the new list" do
      expect(ten.unshift(0)).to eq RDF::List[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    end
  end

  describe RDF::List, "#clear" do
    it "empties list" do
      expect(ten.clear).to eq RDF::List[]
    end
  end

  describe RDF::List, "#eql?" do
    it "requires an argument" do
      expect { empty.send(:eql?) }.to raise_error(ArgumentError)
    end

    it "returns true when given the same list" do
      expect(ten).to eql(ten)
    end

    it "needs work"
  end

  describe RDF::List, "#<=>" do
    it "requires an argument" do
      expect { empty.send(:<=>) }.to raise_error(ArgumentError)
    end

    it "returns 0 when given the same list" do
      expect(ten).to eq ten
    end
  end

  describe RDF::List, "#==" do
    it "requires an argument" do
      expect { empty.send(:==) }.to raise_error(ArgumentError)
    end

    it "returns true when given the same list" do
      expect(ten).to eq ten
    end
  end

  describe RDF::List, "#===" do
    it "requires an argument" do
      expect { empty.send(:===) }.to raise_error(ArgumentError)
    end

    it "returns true when given the same list" do
      expect(ten).to eq ten
    end

    it "needs work"
  end

  describe RDF::List, "#empty?" do
    it "requires no arguments" do
      expect { empty.empty? }.not_to raise_error
    end

    it "returns a boolean" do
      expect(empty).to be_empty
      expect(abc).not_to be_empty
      expect(ten).not_to be_empty
    end
  end

  describe RDF::List, "#length" do
    it "requires no arguments" do
      expect { empty.length }.not_to raise_error
    end

    it "returns an integer" do
      expect(empty.length).to be_an(Integer)
    end

    it "returns the length of the list" do
      expect(empty.length).to eq 0
      expect(abc.length).to eq 3
      expect(ten.length).to eq 10
    end
  end

  describe RDF::List, "#size" do
    it "aliases #length" do
      expect(empty.size).to eq empty.length
      expect(ten.size).to eq ten.length
    end
  end

  describe RDF::List, "#index" do
    it "accepts one argument" do
      expect { ten.index(nil) }.not_to raise_error
    end
  end

  describe RDF::List, "#slice using an element index" do
    it "accepts one argument" do
      expect { ten.slice(0) }.not_to raise_error
    end

    it "returns a value" do
      expect(ten.slice(0)).to be_a_value
    end
  end

  describe RDF::List, "#slice using a start index and a length" do
    it "accepts two arguments" do
      expect { ten.slice(0, 9) }.not_to raise_error
    end

    it "returns a value" do
      expect(ten.slice(0, 9)).to be_a_value
    end
  end

  describe RDF::List, "#slice using a range" do
    it "accepts one argument" do
      expect { ten.slice(0..9) }.not_to raise_error
    end
  end

  describe RDF::List, "#fetch" do
    it "requires one argument" do
      expect { ten.fetch }.to raise_error(ArgumentError)
      expect { ten.fetch(0) }.not_to raise_error
    end

    it "returns a value" do
      expect(ten.fetch(0)).to be_a_value
    end

    it "returns the value at the given index" do
      expect(ten.fetch(0)).to eq RDF::Literal.new(1)
      expect(ten.fetch(9)).to eq RDF::Literal.new(10)
    end

    it "raises IndexError for invalid indexes" do
      expect { ten.fetch(20) }.to raise_error(IndexError)
    end
  end

  describe RDF::List, "#fetch with a default value" do
    it "accepts two arguments" do
      expect { ten.fetch(0, nil) }.not_to raise_error
    end

    it "returns the second argument for invalid indexes" do
      expect { ten.fetch(20, nil) }.not_to raise_error
      expect(ten.fetch(20, true)).to eq true
    end
  end

  describe RDF::List, "#fetch with a block" do
    it "yields to the given block for invalid indexes" do
      expect { ten.fetch(20) { |index| } }.not_to raise_error
      expect(ten.fetch(20) { |index| true }).to be_true
    end
  end

  describe RDF::List, "#at" do
    it "accepts one argument" do
      expect { ten.at(0) }.not_to raise_error
    end
  end

  describe RDF::List, "#nth" do
    it "aliases #at" do
      (1..10).each do |n|
        expect(ten.nth(n)).to eq ten.at(n)
      end
    end
  end

  ORDINALS.each_with_index do |ordinal, index|
    describe RDF::List, "##{ordinal}" do
      it "requires no arguments" do
        expect { ten.__send__(ordinal.to_sym) }.not_to raise_error
      end

      it "returns a value" do
        expect(ten.__send__(ordinal.to_sym)).to be_a_value
      end

      it "returns the #{ordinal} value in the list" do
        expect(ten.__send__(ordinal.to_sym)).to eq RDF::Literal.new(index + 1)
      end
    end
  end

  describe RDF::List, "#last" do
    it "requires no arguments" do
      expect { ten.last }.not_to raise_error
    end
  end

  describe RDF::List, "#rest" do
    it "requires no arguments" do
      expect { ten.rest }.not_to raise_error
    end
  end

  describe RDF::List, "#tail" do
    it "requires no arguments" do
      expect { ten.tail }.not_to raise_error
    end
  end

  describe RDF::List, "#first_subject" do
    it "requires no arguments" do
      expect { ten.first_subject }.not_to raise_error
    end
  end

  describe RDF::List, "#rest_subject" do
    it "requires no arguments" do
      expect { ten.rest_subject }.not_to raise_error
    end
  end

  describe RDF::List, "#last_subject" do
    it "requires no arguments" do
      expect { ten.last_subject }.not_to raise_error
    end
  end

  describe RDF::List, "#each_subject without a block" do
    it "requires no arguments" do
      expect { ten.each_subject }.not_to raise_error
    end

    it "returns an enumerator" do
      expect(abc.each_subject).to be_an_enumerator
    end
  end

  describe RDF::List, "#each_subject with a block" do
    it "requires no arguments" do
      expect { ten.each_subject { |subject| } }.not_to raise_error
    end

    it "yields all subject terms in the list" do
      expect {|b| ten.each_subject(&b)}.to yield_control.exactly(10).times
    end
  end

  describe RDF::List, "#each without a block" do
    it "requires no arguments" do
      expect { ten.each }.not_to raise_error
    end

    it "returns an enumerator" do
      expect(abc.each_subject).to be_an_enumerator
    end
  end

  describe RDF::List, "#each with a block" do
    it "requires no arguments" do
      expect { ten.each { |value| } }.not_to raise_error
    end

    it "yields the correct number of times" do
      expect(abc.each.count).to eq 3
      expect(ten.each.count).to eq 10
    end
  end

  describe RDF::List, "#each_statement without a block" do
    it "requires no arguments" do
      expect { ten.each_statement }.not_to raise_error
    end

    it "returns an enumerator" do
      expect(abc.each_subject).to be_an_enumerator
    end
  end

  describe RDF::List, "#each_statement with a block" do
    it "requires no arguments" do
      expect { ten.each_statement { |statement| } }.not_to raise_error
    end

    it "yields the correct number of times" do
      expect(abc.each_statement.count).to eq 3 * 3
      expect(ten.each_statement.count).to eq 10 * 3
    end

    it "yields statements" do
      expect {|b| ten.each_statement(&b)}.to yield_control.at_least(10).times
      ten.each_statement do |statement|
        expect(statement).to be_a_statement
      end
    end
  end

  describe RDF::List, "#join" do
    it "requires no arguments" do
      expect { empty.join }.not_to raise_error
    end

    it "accepts one argument" do
      expect { empty.join(', ') }.not_to raise_error
    end

    it "returns a string" do
      expect(ten.join).to be_a(String)
    end

    it "returns a particular string" do
      expect(ten.join).to eq '12345678910'
      expect(ten.join(',')).to eq '1,2,3,4,5,6,7,8,9,10'
    end
  end

  describe RDF::List, "#reverse" do
    it "requires no arguments" do
      expect { empty.reverse }.not_to raise_error
    end

    it "returns a list" do
      expect(ten.reverse).to be_a_list
    end

    it "returns the values reversed" do
      expect(ten.reverse.first).to eq RDF::Literal.new(10)
    end
  end

  describe RDF::List, "#sort without a block" do
    it "requires no arguments" do
      expect { empty.sort }.not_to raise_error
    end

    it "returns a list" do
      expect(ten.sort).to be_a_list
    end
  end

  describe RDF::List, "#sort with a block" do
    it "requires no arguments" do
      expect { empty.sort { |a, b| } }.not_to raise_error
    end

    it "returns a list" do
      expect(ten.sort { |a, b| a <=> b }).to be_a_list
    end
  end

  describe RDF::List, "#sort_by with a block" do
    it "requires no arguments" do
      expect { empty.sort_by { |value| } }.not_to raise_error
    end

    it "returns a list" do
      expect(ten.sort_by(&:to_i)).to be_a_list
    end
  end

  describe RDF::List, "#uniq" do
    it "requires no arguments" do
      expect { empty.uniq }.not_to raise_error
    end

    it "returns a list" do
      expect(ten.uniq).to be_a_list
    end

    it "returns a list with duplicate values removed" do
      expect(RDF::List[1, 2, 2, 3].uniq).to eq RDF::List[1, 2, 3]
    end
  end

  describe RDF::List, "#to_a" do
    it "requires no arguments" do
      expect { empty.to_a }.not_to raise_error
    end

    it "returns an array" do
      expect(empty.to_a).to be_an(Array)
    end

    it "returns an array of the correct size" do
      expect(empty.to_a.size).to eq empty.length
      expect(abc.to_a.size).to eq abc.length
      expect(ten.to_a.size).to eq ten.length
    end
  end

  describe RDF::List, "#to_set" do
    it "requires no arguments" do
      expect { empty.to_set }.not_to raise_error
    end

    it "returns a set" do
      expect(empty.to_set).to be_a(Set)
    end

    it "returns a set of the correct size" do
      expect(empty.to_set.size).to eq empty.length
      expect(abc.to_set.size).to eq abc.length
      expect(ten.to_set.size).to eq ten.length
    end

    it "returns a set without duplicates" do
      expect(RDF::List[1, 2, 2, 3].to_set.map(&:to_i).sort).to eq [1, 2, 3]
    end
  end

  describe RDF::List, "#to_s" do
    it "requires no arguments" do
      expect { empty.to_s }.not_to raise_error
    end

    it "returns a string" do
      expect(empty.to_s).to be_a(String)
    end
  end

  describe RDF::List, "#inspect" do
    it "requires no arguments" do
      expect { empty.inspect }.not_to raise_error
    end

    it "returns a string" do
      expect(empty.inspect).to be_a(String)
    end
  end

  describe RDF::List::NIL do
    it "#subject returns rdf:nil" do
      expect(RDF::List::NIL.subject).to eq RDF.nil
    end

    it "#frozen? returns true" do
      expect(RDF::List::NIL).to be_frozen
    end

    it "#empty? returns true" do
      expect(RDF::List::NIL).to be_empty
    end

    it "#[] returns an empty array" do
      expect(RDF::List::NIL.to_a).to eq []
    end

    it "#inspect returns the constant name" do
      expect(RDF::List::NIL.inspect).to eq 'RDF::List::NIL'
    end
  end

  context "Error cases" do
    context "RDFa List construction" do
      let(:list) {RDF::List.new}
      before(:each) do
        list << RDF::Literal("Foo")
      end
      subject {list}
      its(:statements) do
        list.each_statement do |s|
          expect(s.subject).to be_a_node
          expect(s).to be_valid
        end
      end
    end

    context "Turtle List construction" do
      subject {RDF::List.new(RDF::Node("n"), nil, %w(a))}
      its(:length) {should == 1}
    end
  end

  context "Examples" do
    subject {RDF::List[1, 2, 3]}
    it "Constructing a new list" do
      expect(subject).to be_a_list
      expect(RDF::List[]).to be_a_list
      expect(RDF::List[*(1..10)]).to be_a_list
      expect(subject).to be_a_list
      expect(RDF::List["foo", "bar"]).to be_a_list
      expect(RDF::List["a", 1, "b", 2, "c", 3]).to be_a_list
    end

    describe(:&) do
      it "conjunction of lists" do
        {
          (RDF::List[1, 2] & RDF::List[1, 2])       => RDF::List[1, 2],
          (RDF::List[1, 2] & RDF::List[2, 3])       => RDF::List[2],
          (RDF::List[1, 2] & RDF::List[3, 4])       => RDF::List[],
        }.each do |input, output|
          expect(input).to eq output
        end
      end
    end

    describe(:|) do
      it "union of lists" do
        {
          (RDF::List[1, 2] | RDF::List[1, 2])       => RDF::List[1, 2],
          (RDF::List[1, 2] | RDF::List[2, 3])       => RDF::List[1, 2, 3],
          (RDF::List[1, 2] | RDF::List[3, 4])       => RDF::List[1, 2, 3, 4],
        }.each do |input, output|
          expect(input).to eq output
        end
      end
    end

    describe(:+) do
      it "sum of lists" do
        {
          (RDF::List[1, 2] + RDF::List[3, 4])       => RDF::List[1, 2, 3, 4],
        }.each do |input, output|
          expect(input).to eq output
        end
      end
    end

    describe(:-) do
      it "difference of lists" do
        {
          (RDF::List[1, 2, 2, 3] - RDF::List[2])       => RDF::List[1, 3],
        }.each do |input, output|
          expect(input).to eq output
        end
      end
    end

    describe(:*) do
      it "multiplicity of lists" do
        {
          (subject * 2)       => RDF::List[1, 2, 3, 1, 2, 3],
          (subject * "," )    => "1,2,3",
        }.each do |input, output|
          expect(input).to eq output
        end
      end
    end

    describe(:[]) do
      it "index of lists" do
        {
          subject[0] => RDF::Literal(1)
        }.each do |input, output|
          expect(input).to eq output
        end
      end
    end

    describe(:<<) do
      it "append to list" do
        {
          (RDF::List[] << 1 << 2 << 3) => subject
        }.each do |input, output|
          expect(input).to eq output
        end
      end
    end

    describe(:<=>) do
      it "compare lists" do
        {
          (RDF::List[1] <=> RDF::List[1]) => 0,
          (RDF::List[1] <=> RDF::List[2]) => -1,
          (RDF::List[2] <=> RDF::List[1]) => 1,
        }.each do |input, output|
          expect(input).to eq output
        end
      end
    end

    describe(:empty?) do
      it "is empty" do
        {
          RDF::List[].empty?        => true,
          subject.empty? => false,
        }.each do |input, output|
          expect(input).to eq output
        end
      end
    end

    describe(:length) do
      it "is what it is" do
        {
          RDF::List[].length        => 0,
          subject.length => 3,
        }.each do |input, output|
          expect(input).to eq output
        end
      end
    end

    describe(:index) do
      it "is what it is" do
        {
          RDF::List['a', 'b', 'c'].index('a') => 0,
          RDF::List['a', 'b', 'c'].index('d') => nil,
        }.each do |input, output|
          expect(input).to eq output
        end
      end
    end

    describe(:slice) do
      it "slices lists" do
        {
          subject.slice(0)    => RDF::Literal(1),
          subject.slice(0, 2) => RDF::List[1, 2],
          subject.slice(0..2) => RDF::List[1, 2, 3]
        }.each do |input, output|
          expect(input).to eq output
        end
      end
    end

    describe(:fetch) do
      it "fetches lists" do
        {
          subject.fetch(0)             => RDF::Literal(1),
          subject.fetch(4, nil)        => nil,
          subject.fetch(4) { |n| n*n } => 16,
        }.each do |input, output|
          expect(input).to eq output
        end
        expect {subject.fetch(4).to raise_error(IndexError)}
      end
    end

    describe(:at) do
      it "returns element" do
        {
          subject.at(0)             => RDF::Literal(1),
          subject.at(4)             => nil,
        }.each do |input, output|
          expect(input).to eq output
        end
      end
    end

    context "offsets" do
      {
        :first => 1,
        :second => 2,
        :third => 3,
        :fourth => 4,
        :fifth => 5,
        :sixth => 6,
        :seventh => 7,
        :eighth => 8,
        :ninth => 9,
        :tenth => 10,
        :last => 10,
        :rest => RDF::List[2, 3, 4, 5, 6, 7, 8, 9, 10],
        :tail => RDF::List[10],
      }.each do |method, value|
        describe "##{method}" do
          it do
            v = value.is_a?(RDF::Value) ? value : RDF::Literal(value)
            expect(ten.send(method)).to eq v
          end
        end
      end
    end

    describe(:first_subject) do
      it "BNode of first subject" do
        r = subject.first_subject
        expect(r).to be_a_node
        expect(subject.graph.first_object(:subject => r, :predicate => RDF.first)).to eq RDF::Literal(1)
      end
    end

    describe(:rest_subject) do
      it "BNode of rest subject" do
        r = subject.rest_subject
        expect(r).to be_a_node
        expect(subject.graph.first_object(:subject => r, :predicate => RDF.first)).to eq RDF::Literal(2)
      end
    end

    describe(:last_subject) do
      it "BNode of last subject" do
        r = subject.last_subject
        expect(r).to be_a_node
        expect(subject.graph.first_object(:subject => r, :predicate => RDF.rest)).to eq RDF.nil
      end
    end

    describe(:each_subject) do
      it "yields nodes" do
        expect {|b| subject.each_subject(&b)}.to yield_successive_args(RDF::Node, RDF::Node, RDF::Node)
      end
    end

    describe(:each) do
      it "yields values" do
        expect {|b| subject.each(&b)}.to yield_successive_args(*subject.to_a)
      end
    end

    describe(:each_statement) do
      it "yields statements" do
        expect {|b| subject.each_statement(&b)}.to yield_successive_args(*([RDF::Statement] * 9))
      end
    end

    describe(:join) do
      it "joins elements" do
        {
          subject.join       => subject.to_a.join,
          subject.join(", ") => subject.to_a.join(", "),
        }.each do |input, output|
          expect(input).to eq output
        end
      end
    end

    describe(:reverse) do
      it "reverses elements" do
        {
          subject.reverse       => RDF::List[*subject.to_a.reverse],
        }.each do |input, output|
          expect(input).to eq output
        end
      end
    end

    describe(:sort) do
      it "sorts elements" do
        {
          RDF::List[2, 3, 1].sort => RDF::List[1, 2, 3]
        }.each do |input, output|
          expect(input).to eq output
        end
      end
    end

    describe(:sort_by) do
      it "sorts elements" do
        {
          RDF::List[2, 3, 1].sort_by(&:to_i) => RDF::List[1, 2, 3]
        }.each do |input, output|
          expect(input).to eq output
        end
      end
    end

    describe(:uniq) do
      it "uniquifies elements" do
        {
          RDF::List[1, 2, 2, 3].uniq => RDF::List[1, 2, 3]
        }.each do |input, output|
          expect(input).to eq output
        end
      end
    end

    describe(:to_a) do
      it "de-lists elements" do
        {
          RDF::List[].to_a        => [],
          RDF::List[1, 2, 3].to_a => [RDF::Literal(1), RDF::Literal(2), RDF::Literal(3)],
        }.each do |input, output|
          expect(input).to eq output
        end
      end
    end

    describe(:to_set) do
      it "de-lists elements" do
        {
          RDF::List[1, 2, 3].to_set               => Set[RDF::Literal(1), RDF::Literal(2), RDF::Literal(3)]
        }.each do |input, output|
          expect(input).to eq output
        end
      end
    end

    describe(:to_s) do
      it "serializes elements" do
        {
          RDF::List[].to_s        => "RDF::List[]",
          RDF::List[1, 2, 3].to_s => "RDF::List[1, 2, 3]",
        }.each do |input, output|
          expect(input).to eq output
        end
      end
    end
  end
end
