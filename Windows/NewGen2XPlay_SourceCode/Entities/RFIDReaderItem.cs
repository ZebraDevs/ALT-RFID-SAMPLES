
namespace Symbol.RFID.SDK.ZEBRAGen2XDemoApp.Entities
{
    /// <summary>
    /// This is used to create device info object which is used in filling combobox reader list.
    /// </summary>
    public class RFIDReaderItem
    {
        public RFIDReaderItem(RFIDReaderItemInfo deviceInfo)
        {
            Id = deviceInfo.HostAddress;
            Text = deviceInfo.FriendlyName;
            Value = deviceInfo.Reader;
            CommunicationMode = deviceInfo.CommunicationMode.ToString();
        }

        public string CommunicationMode { get; private set; }
        public string Text { get; private set; }
        public object Value { get; private set; }
        public string Id { get; private set; }
        public override string ToString()
        {
            return Text;
        }
    }
}

