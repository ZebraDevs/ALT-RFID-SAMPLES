namespace Symbol.RFID.SDK.ZEBRAGen2XDemoApp.Entities
{
    public class TagData
    {
        #region Private Fields
        private string tagId;
        private sbyte peakRSSI;
        private ushort phase;
        private ushort tagSeenCount;
        private ushort antennaID;
        private long tagSeenTotalCount = 0;
        private int channelIndex = 0;
        private string accessOperations = "";
        private ushort pc = 0;
        private bool selected = false;

        #endregion

        #region Public Properties

        
        /// <summary>
        /// Gets the Tag ID 
        /// </summary>
        public string TagID { get => tagId; set => tagId = value; }

        /// <summary>
        /// Gets the Peak RSSI 
        /// </summary>
        public sbyte PeakRSSI { get => peakRSSI; set => peakRSSI = value; }

        /// <summary>
        /// Gets the Phase 
        /// </summary>
        public ushort Phase { get => phase; set => phase = value; }
        /// <summary>
        /// Gets the antenna ID on which this tag is seen
        /// </summary>
        public ushort AntennaID { get => antennaID; set => antennaID = value; }

        /// <summary>
        /// Gets the Tag seen count
        /// </summary>
        public ushort TagSeenCount { get => tagSeenCount; set => tagSeenCount = value; }

        /// <summary>
        /// Tag Seen Total Count
        /// </summary>
        public long TagSeenTotalCount { get => tagSeenTotalCount; set => tagSeenTotalCount = value; }
      
        /// <summary>
        /// Taf Access operations
        /// </summary>
        public string AccessOperations { get => accessOperations; set => accessOperations = value; }
  
        /// <summary>
        /// Channel Index
        /// </summary>
        public int ChannelIndex { get => channelIndex; set => channelIndex = value; }

        /// <summary>
        /// Get/Set PC (Protocol Control) value
        /// </summary>
        public ushort PC { get => pc; set => pc = value; }

        /// <summary>
        /// Tag Selected
        /// </summary>
        public bool Selected { get => selected; set => selected = value; }
        #endregion
    }
}
