using Symbol.RFID.SDK.ZEBRAGen2XDemoApp.Entities;
using Symbol.RFID.SDK.Domain.Reader;
using System;
using System.Collections.Generic;

namespace Symbol.RFID.SDK.ZEBRAGen2XDemoApp
{
    /// <summary>
    /// Represents all supported features from the RFID SDK which can be used with RFID SDK based any application developement.  
    /// </summary>
    /// <remarks>This library class can be directly copied from here and reuse with your RFID SDK based sample application.</remarks>
    public class RFIDLibraryUtility
    {
        #region Home Operations

        /// <summary>
        /// Initializes the readers.
        /// </summary>
        public static List<IRfidReaderInfo> InitReaderList(ReaderCommunicationMode mode)
        {
            var readerManager = RfidSdk.ReaderManagementServicesFactory.Create(mode);
            //get available readers list
            var readerInfoList = readerManager.GetReaders(ReaderSearchOptions.AllReaders);

            return readerInfoList;
        }

        /// <summary>
        ///Creates reader instance based on reader information.
        /// </summary>
        /// <param name="readerInfo"></param>
        /// <returns></returns>
        public static IRfidReader CreateReader(IRfidReaderInfo readerInfo)
        {
            return RfidSdk.RfidReaderFactory.Create(readerInfo);
        }

        /// <summary>
        /// Connects the device.
        /// </summary>
        public static void Connect(IRfidReader reader)
        {
            reader.Connect();
        }

        /// <summary>
        /// Disconnects the device.
        /// </summary>
        public static void Disconnect(IRfidReader reader)
        {
            //call when reader manually disconnect
            reader.Disconnect();
        }

        #endregion

        #region Inventory Operations

        /// <summary>
        /// Perform inventory process.
        /// </summary>
        /// <param name="reader"></param>
        public static void InventoryPerfom(IRfidReader reader)
        {
            reader.Inventory.Perform();
        }

        /// <summary>
        /// Stops an ongoing inventory.
        /// </summary>
        /// <param name="reader"></param>
        public static void StopInventory(IRfidReader reader)
        {
            reader.Inventory.Stop();
        }

        /// <summary>
        /// Get batch tags once the inventory in batch mode.
        /// </summary>
        public static void GetBatchedTags(IRfidReader reader)
        {
            try
            {
                if (reader != null)
                {
                    reader.Inventory.GetBatchedTags();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// Purge tags.
        /// </summary>
        public static void PurgeTags(IRfidReader reader)
        {
            try
            {
                if (reader != null)
                {
                    reader.Inventory.PurgeTags();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// Fetches an array of tags that was read by the reader.
        /// </summary>
        /// <param name="numberOfTags">Number of Tags that is to be fetched.</param>
        /// <param name="reader"></param>
        /// <returns>A list of TagDataInfo if the method succeeds or an empty array if no Tags were available.</returns>
        public static List<ITagData> GetReadTags(int numberOfTags, IRfidReader reader)
        {
            return reader.Inventory.GetReadTags(numberOfTags);
        }

        /// <summary>
        /// Get Tag data via queue
        /// </summary>
        /// <param name="reader"></param>
        /// <returns></returns>
        public static ITagData GetNextTagDataReceived(IRfidReader reader)
        {
            return reader.Inventory.GetNextTagDataReceived();
        }

        #endregion

        /// <summary>
        /// Gets device status in terms of battery, power and temperature.
        /// </summary>
        /// <param name="battery">battery events required.</param>
        /// <param name="power">power events required.</param>
        /// <param name="temperature">temperature events required.</param>
        public static void GetDeviceStatus(IRfidReader reader, bool batteryStatus, bool powerStatus, bool temperatureStatus)
        {
            reader.Configurations.GetDeviceStatus(batteryStatus, powerStatus, temperatureStatus);
        }

        #region Singulation

        /// <summary>
        /// Gets the singulation control.
        /// </summary>
        /// <param name="reader"></param>
        /// <param name="curAntennaID">Antenna ID</param>
        /// <returns></returns>
        public static SingulationControl GetSingulation(IRfidReader reader, int curAntennaID)
        {
            return reader.Configurations.Antennas[curAntennaID].SingulationControl;
        }

        /// <summary>
        /// Sets the singulation control.
        /// </summary>
        /// <param name="reader"></param>
        /// <param name="curAntennaID"></param>
        /// <param name="singulationControl"></param>
        public static void SetSingulation(IRfidReader reader, int curAntennaID, SingulationControl singulationControl)
        {
            reader.Configurations.Antennas[curAntennaID].SingulationControl = singulationControl;
        }

        #endregion

        /// <summary>
        /// Sets IsTriggerRepeat bool value.
        /// </summary>
        /// <param name="reader"></param>
        /// <param name="isTriggerRepeat"></param>
        public static bool IsTriggerRepeat(IRfidReader reader)
        {
            var isTriggerRepeat = false;

            if (reader != null)
            {
                var startTriggerType = reader.Configurations.TriggerInfo.StartTrigger.Type;

                if (startTriggerType == START_TRIGGER_TYPE.START_TRIGGER_TYPE_PERIODIC || startTriggerType == START_TRIGGER_TYPE.START_TRIGGER_TYPE_HANDHELD)
                {
                    isTriggerRepeat = true;
                }
            }
            return isTriggerRepeat;

        }

        /// <summary>
        /// Gets the batch mode configuration.
        /// </summary>
        /// <param name="reader"></param>
        /// <returns></returns>
        public static BATCH_MODE GetBatchMode(IRfidReader reader)
        {
            return reader.Configurations.BatchModeConfig;
        }

        /// <summary>
        /// Sets the batch mode configuration.
        /// </summary>
        /// <param name="reader"></param>
        /// <param name="batchMode"></param>
        public static void SetBatchMode(IRfidReader reader, BATCH_MODE batchMode)
        {
            reader.Configurations.BatchModeConfig = batchMode;
            ActiveReaderStatus.BatchMode = batchMode;
        }

        // Impinj specific operations
        #region Inpinj Operations

        /// <summary>
        /// Impinj - Protect TAG
        /// </summary>
        /// <param name="reader">RFID reader</param>
        /// <param name="tagID">TagID/ tag pattern to protect</param>
        /// <param name="pwd">password</param>
        /// <param name="antennaID">Antenna id</param>
        public static void ImpinjProtectTag(IRfidReader reader, string tagID,string pwd, short antennaID)
        {
            reader.ImpinjExtensions.EnableTagProtection(tagID, pwd, antennaID);
        }

        /// <summary>
        /// Impinj - Unrotect TAG
        /// </summary>
        /// <param name="reader">RFID reader</param>
        /// <param name="tagID">TagID/ tag pattern to unprotect</param>
        /// <param name="pwd">Password</param>
        /// <param name="antennaID">Antenna id</param>
        public static void ImpinjUnprotectTag(IRfidReader reader, string tagID, string pwd, short antennaID)
        {
            reader.ImpinjExtensions.DisableTagProtection(tagID, pwd, antennaID);
        }

        /// <summary>
        /// Impinj - Fast ID
        /// </summary>
        /// <param name="reader">RFID reader</param>
        /// <param name="enableFasiID">enable FastID</param>
        /// <param name="antennaID">Antenna id</param>
        public static void ImpinjFastID(IRfidReader reader, bool enableFastID, short antennaID)
        {
            reader.ImpinjExtensions.SetFastID(enableFastID, antennaID);
        }

        /// <summary>
        /// Impinj - Tag Focus
        /// </summary>
        /// <param name="reader">RFID reader</param>
        /// <param name="enableTagFocus">enable tag focus</param>
        /// <param name="antennaID">Antenna id</param>
        public static void ImpinjTagFocus(IRfidReader reader, bool enableTagFocus, short antennaID)
        {
            reader.ImpinjExtensions.SetTagFocus(enableTagFocus,antennaID);
        }


        /// <summary>
        /// Impinj - Set Tag Quiet
        /// </summary>
        /// <param name="reader">RFID reader</param>
        /// <param name="tagQuietMasks">Tag quiet mask</param>
        /// <param name="target">Tag quiet Filter target</param>
        /// <param name="action">Tag quiet filter action</param>
        /// <param name="antennaID">Antenna id</param>
        public static void ImpinjTagQuiet(IRfidReader reader, TagQuietMask[] tagQuietMasks, FILTER_TARGET target, FILTER_ACTION action, short antennaID)
        {
            reader.ImpinjExtensions.SetTagQuiet(tagQuietMasks, target, action, antennaID);
        }

        /// <summary>
        /// Impinj - Set Tag Quiet
        /// </summary>
        /// <param name="reader">RFID reader</param>
        /// <param name="pwd">password</param>
        /// <param name="enableTagVisibility">Enable tag visibility true/false</param>
        /// <param name="antennaID">Antenna id</param>
        public static void ImpinjTagVisibility(IRfidReader reader, string pwd, bool enableTagVisibility,short antennaID)
        {
            if (enableTagVisibility)
            {
                reader.ImpinjExtensions.EnableTagVisibility(pwd, antennaID);
            }
            else
            {
                reader.ImpinjExtensions.DisableTagVisibility(pwd, antennaID);
            }
        }
        #endregion
    }
}
