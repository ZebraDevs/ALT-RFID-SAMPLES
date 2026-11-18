using Symbol.RFID.SDK.ZEBRAGen2XDemoApp.Entities;
using Symbol.RFID.SDK.Domain.Reader;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

namespace Symbol.RFID.SDK.ZEBRAGen2XDemoApp
{
    public class TagUtility
    {
        #region Public Methods

        public static TagData GetTagData(ushort antennaId, string tagId, ushort tagSeenCount, sbyte peakRSSI, ushort phase,int channelIndex,ushort PC)
        {
            TagData data = new TagData();
            data.AntennaID = antennaId;
            data.TagID = tagId;
            data.TagSeenCount = tagSeenCount;
            data.PeakRSSI = peakRSSI;
            data.Phase = phase;
            data.ChannelIndex = channelIndex;
            data.PC = PC;
            return data;
        }

        /// <summary>
        /// This method fetches a array of Tags that was read by the reader. 
        /// Tags will be read from the Reader using methods: Actions.Inventory.Perform or 
        /// Actions.TagAccess.ReadEvent or Actions.TagAccess.ReadWait.
        /// </summary>
        /// <param name="numberOfTags">Number of Tags that is to be fetched</param>
        /// <returns>An array of TagData if the method succeeds or an empty array if no Tags were available</returns>
        public static TagData[] GetReadTags(int numberOfTags, IRfidReader reader)
        {
            List<ITagData> tagDataReceived = RFIDLibraryUtility.GetReadTags(numberOfTags, reader);

            var temp = new Queue();
            foreach (ITagData dataReceived in tagDataReceived)
            {
                var tagData = new TagData
                {
                    AntennaID = dataReceived.AntennaID,
                    TagID = dataReceived.EPCId,
                    TagSeenCount = dataReceived.TagSeenCount,
                    PeakRSSI = dataReceived.RSSI,
                    Phase = dataReceived.Phase,
                    ChannelIndex = dataReceived.ChannelIndex,
                    PC = dataReceived.PC,
                };

                temp.Enqueue(tagData);
            }
            return (temp.Count > 0) ? temp.ToArray().OfType<TagData>().ToArray() : null;
        }

        #endregion
    }
}
