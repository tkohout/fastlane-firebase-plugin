describe Fastlane::Actions::FirebaseAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The firebase plugin is working!")

      Fastlane::Actions::FirebaseAction.run(nil)
    end
  end
end
