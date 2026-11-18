using Symbol.RFID.SDK.ZEBRAGen2XDemoApp.Entities;
using System.Xml;

namespace Symbol.RFID.SDK.ZEBRAGen2XDemoApp.Globals
{
    public class TagInfo
    {
        private int rowIndex = -1;
        private long tagSeenCount = 0;
        private double readrate = 0;
        private string tagColor = "W";// W-White, G-Green, Y-Yellow, GR-Gray

        public TagInfo(TagData tg, int rowID, long tagSeenCnt)
        {
            Tag = tg;
            RowIndex = rowID;
            TagSeenTotalCount = tagSeenCnt;
        }
        public TagData Tag { get; set; }
        public int RowIndex { get { return rowIndex; } set { rowIndex = value; } }
        public long TagSeenTotalCount { get { return tagSeenCount; } set { tagSeenCount = value; } }
        public double ReadRate { get { return readrate; } set { readrate = value; } }
        public string TagColor { get { return tagColor; } set { tagColor = value ; } }
    }
}
