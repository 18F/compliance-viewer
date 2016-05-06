describe ZapSummary do
  describe '#top_level' do
    it "returns the highest level with any warnings present" do
      summary = ZapSummary.new('foo',
        'high' => 0,
        'medium' => 2,
        'low' => 7,
        'informational' => 8)
      expect(summary.top_level).to eq('medium')
    end

    it "returns nil if there are no alerts" do
      summary = ZapSummary.new('foo',
        'high' => 0,
        'medium' => 0,
        'low' => 0,
        'informational' => 0)
      expect(summary.top_level).to eq(nil)
    end
  end
end
