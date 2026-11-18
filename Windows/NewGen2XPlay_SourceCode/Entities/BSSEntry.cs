using Symbol.RFID.SDK.Domain.Reader;

namespace Symbol.RFID.SDK.ZEBRAGen2XDemoApp.Entities
{
    /// <summary>
    /// This is used to create BSS entry object which is used in filling combobox.
    /// </summary>
    public class BSSEntry
    {
        public BSSEntry(BasicServiceSet bss)
        {
            Id = bss.SSID;
            Text = bss.SSID + "[" + bss.Status+ "]";
        }

        public string Id { get; private set; }
        public string Text { get; private set; }
        public object Value { get; private set; }

        public override string ToString()
        {
            return Text;
        }
    }
}

