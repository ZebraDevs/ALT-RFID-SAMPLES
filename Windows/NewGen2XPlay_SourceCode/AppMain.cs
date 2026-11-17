using InTheHand.Windows.Forms;
using Symbol.RFID.SDK.ZEBRAGen2XDemoApp.Entities;
using Symbol.RFID.SDK.ZEBRAGen2XDemoApp.Globals;
using Symbol.RFID.SDK.Domain.Reader;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Xml;
using static Symbol.RFID.SDK.ZEBRAGen2XDemoApp.TagQuieting;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace Symbol.RFID.SDK.ZEBRAGen2XDemoApp
{
    public partial class frmMain : Form
    {
        #region Constants

        private const int MAX_OUTPUT_LINES = 1000;
        private const int TAG_QUIET_BATCH_SIZE = 31;

        private const int AntennaID = 1;
        private const int curAntennaIDIndex = 0;
        private bool tagQuiet = false;
        #endregion

        #region Enum

        #endregion

        #region Private Fields

        private List<IRfidReader> readerList = new List<IRfidReader>();
        private int outputLinePos = 0;
        private IRfidReader selectedReader;
        private RFIDReaderItem selectedItem;

        private Dictionary<string, TagInfo> tagList = new Dictionary<string, TagInfo>();
        private List<string> quietTagList = new List<string>();

        private bool isStopPressed;
        private bool isConnected;

        private bool isWaitAnimation = false;
        private bool isConnectedManually = false;

        private bool isBluetoothWatcherInitialized = false;
        private bool isUsbWatcherInitialized = false;
        private bool isIPWatcherInitialized = false;
        private bool isAccessSequenceOperationInProgress = false;

        private string deviceIdWhichRunsInventory = string.Empty;
        bool isPreSetTagQuiteEnabled = false;

        private WaitAnimation waitDialog;
        private System.Windows.Forms.Timer TagQuietTimer;
        private int currentTagQuietBatchIndex = 0;
        private List<string> pendingQuietTags = new List<string>();
        private long TotalTagsToQuit = 0;
        private long CurrentQuitedCount = 0;
        private bool DeleteAllPrefilters = false;


        internal FILTER_ACTION TagQuietAction = FILTER_ACTION.INV_B_OR_DSRT_SL;
        internal FILTER_TARGET TagQuietTarget = FILTER_TARGET.SESSION_S3;
        internal List<TagQuietMaskValue> TagQuietMasks = new List<TagQuietMaskValue>() { TagQuietMaskValue.S2B, TagQuietMaskValue.S3B };


        IRemoteReaderWatcher remoteReaderWatcher = null;
        IRemoteReaderWatcher usbReaderWatcher = null;
        IRemoteReaderWatcher ipReaderWatcher = null;
        Thread InventoryInfoUpdate = null;

        // Thread-based unique tag tracking
        private Thread uniqueTagTrackingThread;
        private volatile bool shouldStopUniqueTagTracking = false;
        private int previousUniqueTagCount = 0;
        private DateTime lastUniqueTagCheckTime;
        private readonly object tagListLock = new object();

 
        #endregion

        #region Public Properties

        public ReaderInfo ReaderInfo { private get; set; }

        #endregion

        #region Constructors

        public frmMain()
        {
            InitializeComponent();
        }

        #endregion

        #region Form Event Handlers
        private void FrmAppMain_Load(object sender, EventArgs e)
        {
            PopulateControls();
            UpdateUIControls(false, false);
            grdTags.CellContentClick += grdTags_CellContentClick;
            btnUnquiet.Text = "UN-QUIET";
            // Initialize TagQuietTimer
            TagQuietTimer = new System.Windows.Forms.Timer();
            TagQuietTimer.Tick += TagQuietTimer_Tick;

            Console.WriteLine($"{DateTime.Now:yyyy-MM-dd HH:mm:ss.fff} - UniqueTagTimer initialized for thread-based tracking");

            try
            {
                Task.Run(() =>
                {
                    Cursor.Current = Cursors.WaitCursor;
                    BeginInvoke((MethodInvoker)delegate
                    {
                        OutputText("Discovery is in progress.Please wait.");
                        UpdateStatusMessage("Discovery is in progress.Please wait.");
                        InitializeReaderWatcher();
                        FillRFIDReadersItems();
                  });
                    Cursor.Current = Cursors.Default;
                });
            }
            catch (Exception ex)
            {
                OutputText(ex.Message);
                DisableControls();
            }
        }



        private void ComboBoxReaders_SelectedIndexChanged(object sender, EventArgs e)
        {
            SetSelectedReader();
            UpdateUIControls(selectedReader.IsConnected);
        }

        private void btnManualConnect_Click(object sender, EventArgs e)
        {
            ManualConnect frmManual = new ManualConnect(this);
            isConnectedManually = true;
            frmManual.ShowDialog();
            ManualConnect();
        }

        private void BtnPairNew_Click(object sender, EventArgs e)
        {
            PairNewReader(this);
            FillRFIDReadersItems();
        }

        private void BtnConnectDisconnect_Click(object sender, EventArgs e)
        {
            Cursor.Current = Cursors.WaitCursor;
            if (string.Equals(btnConnectDisconnect.Text, "CONNECT", StringComparison.OrdinalIgnoreCase))
            {
                Connect(null);
            }
            else
            {
                Disconnect();
            }
        }

        private void BtnInventoryStart_Click(object sender, EventArgs e)
        {
            ShowDefaultTagData();
            PerformInventory();

        }

        DateTime m_InventoryStartTime;
        private void PerformInventory()
        {
            try
            {
                
                // chkSelectAll.Checked = false;
                grdTags.RowTemplate.Height = 20;
                StartInventory();
                m_InventoryStartTime = DateTime.Now;
            }
            catch (Exception ex)
            {
                OutputText(ex.Message);
            }
        }
  
        private void BtnInventoryStop_Click(object sender, EventArgs e)
        {
            try
            {
                Cursor.Current = Cursors.WaitCursor;

                // Execute stop inventory operations on a background task
                Task.Run(() =>
                {
                    try
                    {
                        // Stop inventory first (SDK call - potentially blocking)
                        if (selectedReader != null && selectedReader.IsConnected)
                        {
                            Console.WriteLine($"{DateTime.Now:yyyy-MM-dd HH:mm:ss.fff} - StopInventory task started");
                            RFIDLibraryUtility.StopInventory(selectedReader);
                            Console.WriteLine($"{DateTime.Now:yyyy-MM-dd HH:mm:ss.fff} - StopInventory task completed");
                        }

                        // Update UI on UI thread
                        BeginInvoke((MethodInvoker)delegate
                        {
                            try
                            {
                                isPreSetTagQuiteEnabled = false;
                                TagQuietTimer.Enabled = false;
                                TagQuietTimer.Stop();
                                tagQuiet = false;
                                btnInventoryStart.Enabled = true;
                                btnInventoryStop.Enabled = false;
                                settingsMenuItem.Enabled = true;
                                txtStopTimer.Enabled = txtQuietTime.Enabled = btnUnquiet.Enabled = btnSetTagQuiet.Enabled = true;
                                chkEnableFastID.Enabled = true;
                                chkSelectAll.Enabled = true;
                                chkTagFocus.Enabled = true;
                                // Update internal state
                                deviceIdWhichRunsInventory = string.Empty;
                                ActiveReaderStatus.IsInventoryRunning = false;
                                isAccessSequenceOperationInProgress = false;
                                StopUniqueTagTimer();
                                Cursor.Current = Cursors.Default;
                                Console.WriteLine($"{DateTime.Now:yyyy-MM-dd HH:mm:ss.fff} - Inventory stop completed");
                            }
                            catch (Exception uiEx)
                            {
                                OutputText($"UI update error: {uiEx.Message}");
                                Cursor.Current = Cursors.Default;
                            }
                        });
                    }
                    catch (Exception taskEx)
                    {
                        BeginInvoke((MethodInvoker)delegate
                        {
                            OutputText($"Stop inventory error: {taskEx.Message}");
                            Cursor.Current = Cursors.Default;
                        });
                    }
                });
            }
            catch (Exception ex)
            {
                OutputText(ex.Message);
                Cursor.Current = Cursors.Default;
            }
        }
        private void FrmAppMain_FormClosing(object sender, FormClosingEventArgs e)
        {
            try
            {
                // Stop all timers and threads
                StopUniqueTagTimer();

                if (TagQuietTimer != null)
                {
                    TagQuietTimer.Stop();
                    TagQuietTimer.Dispose();
                }

                if (selectedReader != null && selectedReader.IsConnected)
                {
                    RFIDLibraryUtility.Disconnect(selectedReader);
                }
            }
            catch (Exception ex)
            {
                Debug.Print(ex.Message);
            }
        }

        private void AboutToolStripMenuItem_Click(object sender, EventArgs e)
        {
            About frm = new About(selectedReader, this);
            frm.ShowDialog();
        }

        private void InventoryProtocolToolStripMenuItem_Click(object sender, EventArgs e)
        {
            InventoryMode frm = new InventoryMode(selectedReader, this);
            frm.ShowDialog();
        }
        
        private void SingulationToolStripMenuItem_Click(object sender, EventArgs e)
        {
            ShowSingulationDlg();
        }

        private void BtnPurgeTags_Click(object sender, EventArgs e)
        {
            try
            {
                if (selectedReader != null)
                {  
                    // Clean the inventory tag data list
                    ResetTagInfo();
                    //RFIDLibraryUtility.PurgeTags(selectedReader);
                    OutputText("Purge Tags : Successful");
                    m_InventoryStartTime = DateTime.Now;
                    lbluniquetgs10s.Text = "0";
                    previousUniqueTagCount = 0;
                    lblTotalReadCount.Text = "0";
                }
                grdTags.Rows.Clear();
            }
            catch { }
        }

        private void preFilters_Click(object sender, EventArgs e)
        {
            ShowPreFilter();
        }

        private void lblLog_Click(object sender, EventArgs e)
        {
            txtOutput.Text = string.Empty;
        }

        #endregion


        System.Windows.Forms.Timer tm = new System.Windows.Forms.Timer();

        #region RFIDReader EventHandlers

        /// <summary>
        /// Occurs when a new reader has appeared (paired).
        /// </summary>
        /// <param name="sender">The sender.</param>
        /// <param name="e">The event.</param>
        private void ReaderAppearedHandler(object sender, ReaderStatusChangedEventArgs e)
        {
            var reader = readerList.Find(i => i.ID.Equals(e.RFIDReaderInfo.ID, StringComparison.OrdinalIgnoreCase));

            if (reader == null)
            {
                Task.Run(() => Invoke((MethodInvoker)delegate
                {
                    var deviceInfo = CreateReaderInfoItem(e.RFIDReaderInfo);
                    if (!readerList.Any(r => r.ID == deviceInfo.Reader.ID))
                        readerList.Add(deviceInfo.Reader);

                    AddToReaderList(deviceInfo);

                    var status = e.RFIDReaderInfo.CommunicationMode == ReaderCommunicationMode.Bluetooth ? "Paired" : "Attached";
                    OutputText("Events_Notify: " + status + ".\n");
                }));
            }
        }

        /// <summary>
        /// Occurs when a reader has disappeared (unpaired).
        /// </summary>
        /// <param name="sender">The sender.</param>
        /// <param name="e">The event.</param>
        private void ReaderDisappearedHandler(object sender, ReaderStatusChangedEventArgs e)
        {
            var reader = readerList.Find(i => i.ID.Equals(e.RFIDReaderInfo.ID, StringComparison.OrdinalIgnoreCase));

            if (reader != null)
            {
                Task.Run(() => Invoke((MethodInvoker)delegate
                {
                    var status = e.RFIDReaderInfo.CommunicationMode == ReaderCommunicationMode.Bluetooth ? "Unpaired" : "Detached";
                    OutputText("Event_Notify: " + status + ".\n");

                    if (reader.IsConnected)
                    {
                        Disconnect();
                    }

                    BeginInvoke((MethodInvoker)delegate
                    {
                        UpdateUIControls(false);
                    });

                    RemoveFromReaderList(reader);
                    readerList.Remove(reader);
                }));
            }
        }

        /// <summary>
        /// Occurs when a reader has been connected.
        /// </summary>
        /// <param name="sender">The sender.</param>
        /// <param name="e">The event.</param>
        private void ReaderConnectedHandler(object sender, ReaderStatusChangedEventArgs e)
        {
            var reader = readerList.Find(i => i.ID.Equals(e.RFIDReaderInfo.ID, StringComparison.OrdinalIgnoreCase));
            if (reader != null)
            {
                BeginInvoke((MethodInvoker)delegate
                {
                    OutputText("Event_Notify: Connected.\n");
                });
            }
        }

        /// <summary>
        /// Occurs when a reader has been disconnected.
        /// </summary>
        /// <param name="sender">The sender.</param>
        /// <param name="e">The event.</param>
        private void ReaderDisconnectedHandler(object sender, ReaderStatusChangedEventArgs e)
        {
            if (selectedReader != null && selectedReader.ID == e.RFIDReaderInfo.ID)
            {
                isConnected = false;

                UnRegisterEvents();

                ActiveReaderStatus.Reset();

                BeginInvoke((MethodInvoker)delegate
                {
                    UpdateUIControls(false);
                    selectedReader = null;

                    OutputText("Event_Notify: Disconnected.\n");
                });
            }
        }

        // In class fields:
        private CancellationTokenSource inventoryCts;

        private volatile bool shouldStopInventoryThread;

        /// <summary>
        ///  Occurs when an inventory session started.
        /// </summary>
        /// <param name="sender">The sender.</param>
        /// <param name="e">The event.</param>
        private void Inventory_InventoryStarted(object sender, EventArgs e)
        {
            BeginInvoke((MethodInvoker)delegate
            {
                shouldStopInventoryThread = false;
                InventoryInfoUpdate = new Thread(UpdateInventoryStatus);
                InventoryInfoUpdate.IsBackground = true;
                InventoryInfoUpdate.Start();

                // Start the unique tag tracking thread
                StartUniqueTagTimer();

                // Use the safe start method
                OutputText("Event: Inventory started.\n");
            });
        }

        // Modify UpdateInventoryStatus:
        private void UpdateInventoryStatus()
        {
            while (!shouldStopInventoryThread)
            {
                if (selectedReader != null && selectedReader.IsConnected && ActiveReaderStatus.IsInventoryRunning)
                {
                    UpdateInventoryTime();
                }
                Thread.Sleep(10);
            }
        }





        /// <summary>
        ///  Occurs when an inventory session stops.
        /// </summary>
        /// <param name="sender">The sender.</param>
        /// <param name="e">The event.</param>
        private void Inventory_InventoryStopped(object sender, EventArgs e)
        {
            BeginInvoke((MethodInvoker)delegate
            {
                OutputText("Event: Inventory stopped.\n");
                shouldStopInventoryThread = true;
                lblTime.Text = (DateTime.Now - m_InventoryStartTime).ToString(@"hh\:mm\:ss");

                // Use the safe stop method
                if (!isPreSetTagQuiteEnabled)
                {
                    StopUniqueTagTimer();

                    int finalUniqueCount;
                    lock (tagListLock)
                    {
                        finalUniqueCount = tagList.Count;
                    }

                    int finalNewTags = finalUniqueCount - previousUniqueTagCount;
                    Console.WriteLine($"{DateTime.Now:yyyy-MM-dd HH:mm:ss.fff} - Final unique tags: {finalUniqueCount}, New: {finalNewTags}");
                }

                if (!isPreSetTagQuiteEnabled)
                {
                    deviceIdWhichRunsInventory = string.Empty;
                    ActiveReaderStatus.IsInventoryRunning = false;
                    UpdateInventoryButtons();
                    isStopPressed = false;
                }
            });
        }

        List<TagData> QuiteTagList = new List<TagData>();
        /// <summary>
        /// Occurs when reader read tags.
        /// </summary>
        /// <param name="sender">The sender.</param>
        /// <param name="e">The event.</param>
        private void Inventory_TagDataReceived(object sender, TagDataReceivedEventArgs e)
        {
            if (e != null)
            {
                string id = e.EPCId;
                // Tags which are not having EPCID 
                if (e.EPCId == null)
                {
                    // Show it as empty row.
                    id = "";
                }

                TagData data = TagUtility.GetTagData(e.AntennaID, id, e.TagSeenCount, e.RSSI, e.Phase, e.ChannelIndex, e.PC);

                if (e.TagAccessOperations.Count > 0)
                {
                    StringBuilder tagAccessOperationDetails = new StringBuilder();
                    foreach (var op in e.TagAccessOperations)
                    {
                        tagAccessOperationDetails.AppendLine($"{op.Operation}, Status:{op.OperationStatus}, Memory Bank:{op.MemoryBank}, Data:{op.MemoryBankData}");
                    }
                    data.AccessOperations = tagAccessOperationDetails.ToString();
                }
                var tagDataArr = new TagData[] { data };

                try
                {
                    Invoke((MethodInvoker)delegate
                    {
                        ShowTagData(tagDataArr);
                    });
                }
                catch
                {

                }

            }
            else
            {
                try
                {
                    if (selectedReader != null)
                    {
                        var tagDataArr = TagUtility.GetReadTags(1000, selectedReader);
                        if (tagDataArr != null)
                        {
                            Invoke((MethodInvoker)delegate
                            {
                                ShowTagData(tagDataArr);
                            });
                        }
                    }
                }
                catch (Exception ex)
                {
                    Invoke((MethodInvoker)delegate
                    {
                        OutputText(ex.Message);
                    });
                }
            }
        }

        


        /// <summary>
        /// Occurs when trigger status changes
        /// </summary>
        /// <param name="sender">The sender.</param>
        /// <param name="e">Trigger Status notification event args.</param>
        private void SelectedReader_TriggerStatusNotification(object sender, TriggerStatusNotificationReceivedEventArgs e)
        {
            Invoke((MethodInvoker)delegate
            {
                if (e != null)
                {
                    OutputText("Event_Trigger: TriggerMode = " + e.TriggerMode + ", Trigger Type = " + e.TriggerType);
                }
            });
        }

        private void HexInput_KeyPress(object sender, KeyPressEventArgs e)
        {
            DataUtility.IsHex(e);
        }

        private void NumericInput_KeyPress(object sender, KeyPressEventArgs e)
        {
            DataUtility.IsNumeric(e);
        }

        #endregion

        #region Private Methods

        /// <summary>
        /// Thread method for tracking unique tags every 10 seconds
        /// </summary>
        private void UniqueTagTrackingThreadMethod()
        {
            Console.WriteLine($"{DateTime.Now:yyyy-MM-dd HH:mm:ss.fff} - UniqueTagTrackingThread started");

            DateTime lastCheckTime = DateTime.Now;
            const int checkIntervalSeconds = 10;

            while (!shouldStopUniqueTagTracking)
            {
                try
                {
                    // Sleep for a short interval to avoid busy-waiting
                    Thread.Sleep(100);

                    if (shouldStopUniqueTagTracking)
                        break;

                    // Calculate time difference
                    TimeSpan timeDiff = DateTime.Now - lastCheckTime;

                    // Check if 10 seconds have elapsed
                    if (timeDiff.TotalSeconds >= checkIntervalSeconds)
                    {
                        // Thread-safe read of tagList.Count
                        int currentUniqueTagCount;
                        lock (tagListLock)
                        {
                            currentUniqueTagCount = tagList.Count;
                        }

                        int newUniqueTags = currentUniqueTagCount - previousUniqueTagCount;

                        // Update UI on UI thread
                        BeginInvoke((MethodInvoker)delegate
                        {
                            try
                            {
                                if (newUniqueTags > 0)
                                {
                                    var totaluniqueTags = Convert.ToInt32(lblunqtags.Text);
                                    lbluniquetgs10s.Text = totaluniqueTags < newUniqueTags ? totaluniqueTags.ToString() : newUniqueTags.ToString();
                                }
                                else
                                {
                                    lbluniquetgs10s.Text = "0";
                                }

                                Console.WriteLine($"{DateTime.Now:yyyy-MM-dd HH:mm:ss.fff} - UniqueTagTrackingThread - New tags: {newUniqueTags}, Total: {currentUniqueTagCount}");
                            }
                            catch (Exception ex)
                            {
                                Console.WriteLine($"{DateTime.Now:yyyy-MM-dd HH:mm:ss.fff} - UniqueTagTrackingThread UI update error: {ex.Message}");
                            }
                        });

                        previousUniqueTagCount = currentUniqueTagCount;
                        lastCheckTime = DateTime.Now;
                        lastUniqueTagCheckTime = DateTime.Now;
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"{DateTime.Now:yyyy-MM-dd HH:mm:ss.fff} - UniqueTagTrackingThread error: {ex.Message}");
                    Debug.WriteLine($"UniqueTagTrackingThread exception: {ex}");
                }
            }

            Console.WriteLine($"{DateTime.Now:yyyy-MM-dd HH:mm:ss.fff} - UniqueTagTrackingThread stopped");
        }

        /// <summary>
        /// Safely starts the unique tag tracking thread
        /// </summary>
        private void StartUniqueTagTimer()
        {
            try
            {
                if (uniqueTagTrackingThread == null || !uniqueTagTrackingThread.IsAlive)
                {
                    lock (tagListLock)
                    {
                        previousUniqueTagCount = tagList.Count;
                    }
                    lastUniqueTagCheckTime = DateTime.Now;

                    shouldStopUniqueTagTracking = false;
                    uniqueTagTrackingThread = new Thread(UniqueTagTrackingThreadMethod);
                    uniqueTagTrackingThread.IsBackground = true;
                    uniqueTagTrackingThread.Name = "UniqueTagTrackingThread";
                    uniqueTagTrackingThread.Start();

                    Console.WriteLine($"{DateTime.Now:yyyy-MM-dd HH:mm:ss.fff} - UniqueTagTimer started (thread-based)");
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Error starting UniqueTagTimer: {ex.Message}");
            }
        }

        /// <summary>
        /// Safely stops the unique tag tracking thread
        /// </summary>
        /// <summary>
        /// Safely stops the unique tag tracking thread
        /// </summary>
        private void StopUniqueTagTimer()
        {
            try
            {
                if (uniqueTagTrackingThread != null && uniqueTagTrackingThread.IsAlive)
                {
                    shouldStopUniqueTagTracking = true;

                    // Wait for thread to complete (max 200ms now instead of 2000ms)
                    if (!uniqueTagTrackingThread.Join(200))
                    {
                        Console.WriteLine($"{DateTime.Now:yyyy-MM-dd HH:mm:ss.fff} - UniqueTagTimer thread did not stop gracefully");
                    }

                    uniqueTagTrackingThread = null;
                    Console.WriteLine($"{DateTime.Now:yyyy-MM-dd HH:mm:ss.fff} - UniqueTagTimer stopped");
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Error stopping UniqueTagTimer: {ex.Message}");
            }
        }


        /// <summary>
        /// Populate data grid view view UI control.
        /// </summary>
        private void PopulateControls()
        {
            DataGridViewColumn colTagSel = new DataGridViewCheckBoxColumn();
            colTagSel.HeaderText = " ";
            colTagSel.Name = "TagSelected";
            colTagSel.Width = 25;
            colTagSel.MinimumWidth = 20;
            colTagSel.ReadOnly = false;
            colTagSel.DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleLeft;
            grdTags.Columns.Add(colTagSel);

            DataGridViewColumn colTagID = new DataGridViewTextBoxColumn();
            colTagID.HeaderText = "EPC Tag ID";
            colTagID.Name = "TagID";
            colTagID.Width = 280;
            colTagID.MinimumWidth = 180;
            colTagID.AutoSizeMode = DataGridViewAutoSizeColumnMode.Fill;
            colTagID.ReadOnly = true;
            colTagID.DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleLeft;
            colTagID.ValueType = typeof(string);  // ADD THIS
            grdTags.Columns.Add(colTagID);

            DataGridViewColumn colPeakRSSI = new DataGridViewTextBoxColumn();
            colPeakRSSI.HeaderText = "RSSI";
            colPeakRSSI.Name = "PeakRSSI";
            colPeakRSSI.Width = 80;
            colPeakRSSI.DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleRight;
            colPeakRSSI.ReadOnly = true;
            colPeakRSSI.ValueType = typeof(int);  // ADD THIS (or double, depending on PeakRSSI type)
            grdTags.Columns.Add(colPeakRSSI);

            DataGridViewColumn colTagCount = new DataGridViewTextBoxColumn();
            colTagCount.HeaderText = "Count";
            colTagCount.Name = "TagSeenCount";
            colTagCount.Width = 120;
            colTagCount.DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleRight;
            colTagCount.ReadOnly = true;
            colTagCount.ValueType = typeof(long);  // ADD THIS - Critical fix!
            grdTags.Columns.Add(colTagCount);

            DataGridViewColumn colReadRate = new DataGridViewTextBoxColumn();
            colReadRate.HeaderText = "Read/sec";
            colReadRate.Name = "ReadRate";
            colReadRate.Width = 120;
            colReadRate.DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleRight;
            colReadRate.ReadOnly = true;
            colReadRate.ValueType = typeof(double);  // ADD THIS
            grdTags.Columns.Add(colReadRate);

            DataGridViewColumn colAccOp = new DataGridViewTextBoxColumn();
            colAccOp.HeaderText = "Tag Access Operations";
            colAccOp.Name = "TagAccessOperations";
            colAccOp.Width = 1000;
            colAccOp.DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleLeft;
            colAccOp.DefaultCellStyle.WrapMode = DataGridViewTriState.True;
            colAccOp.ReadOnly = true;
            colAccOp.Visible = false;
            colAccOp.ValueType = typeof(string);  // ADD THIS
            grdTags.Columns.Add(colAccOp);
            grdTags.RowTemplate.Height = 20;
        }

        /// <summary>
        /// Initialize the reader watcher events.
        /// </summary>
        private void InitializeReaderWatcher()
        {
            try
            {
                remoteReaderWatcher = RfidSdk.ReaderWatcherServicesFactory.Create(ReaderCommunicationMode.Bluetooth);
                remoteReaderWatcher.ReaderAppeared += new EventHandler<ReaderStatusChangedEventArgs>(ReaderAppearedHandler);
                remoteReaderWatcher.ReaderDisappeared += new EventHandler<ReaderStatusChangedEventArgs>(ReaderDisappearedHandler);
                remoteReaderWatcher.ReaderConnected += new EventHandler<ReaderStatusChangedEventArgs>(ReaderConnectedHandler);
                remoteReaderWatcher.ReaderDisconnected += new EventHandler<ReaderStatusChangedEventArgs>(ReaderDisconnectedHandler);

                isBluetoothWatcherInitialized = true;
            }
            catch (Exception ex)
            {
                //Print exception to log if Initializing ReaderWatcher failed
                OutputText(ex.Message);
            }

            try
            {
                usbReaderWatcher = RfidSdk.ReaderWatcherServicesFactory.Create(ReaderCommunicationMode.USB);
                usbReaderWatcher.ReaderAppeared += new EventHandler<ReaderStatusChangedEventArgs>(ReaderAppearedHandler);
                usbReaderWatcher.ReaderDisappeared += new EventHandler<ReaderStatusChangedEventArgs>(ReaderDisappearedHandler);
                usbReaderWatcher.ReaderConnected += new EventHandler<ReaderStatusChangedEventArgs>(ReaderConnectedHandler);
                usbReaderWatcher.ReaderDisconnected += new EventHandler<ReaderStatusChangedEventArgs>(ReaderDisconnectedHandler);

                isUsbWatcherInitialized = true;
            }
            catch 
            {
                //Print exception to log if Initializing ReaderWatcher failed
                //OutputText(ex.Message);
            }

            try
            {
                ipReaderWatcher = RfidSdk.ReaderWatcherServicesFactory.Create(ReaderCommunicationMode.IP);
                ipReaderWatcher.ReaderAppeared += new EventHandler<ReaderStatusChangedEventArgs>(ReaderAppearedHandler);
                ipReaderWatcher.ReaderDisappeared += new EventHandler<ReaderStatusChangedEventArgs>(ReaderDisappearedHandler);
                ipReaderWatcher.ReaderConnected += new EventHandler<ReaderStatusChangedEventArgs>(ReaderConnectedHandler);
                ipReaderWatcher.ReaderDisconnected += new EventHandler<ReaderStatusChangedEventArgs>(ReaderDisconnectedHandler);

                isIPWatcherInitialized = true;
            }
            catch 
            {
                //Print exception to log if Initializing ReaderWatcher failed
               // OutputText(ex.Message);
            }
        }

       

        /// <summary>
        /// Disables button controls
        /// </summary>
        private void DisableControls()
        {
            settingsMenuItem.Enabled = false;
            btnConnectDisconnect.Enabled = false;

            (tabInventory as Control).Enabled = false;
        }

        /// <summary>
        /// Updates UI controls.
        /// </summary>
        /// <param name="isConnect">Is connected status</param>
        private void UpdateUIControls(bool isConnect)
        {
            UpdateUIControls(isConnect, false);
        }

        /// <summary>
        /// Updates UI controls.
        /// </summary>
        /// <param name="isConnect">Is connected status</param>
        /// <param name="isReset">Is reset status</param>
        private void UpdateUIControls(bool isConnect, bool isReset)
        {
            if (selectedReader != null && selectedReader.ReaderType == ReaderType.RFD)
            {
                InventoryProtocolToolStripMenuItem.Visible = true;
            }
            else
            {
                InventoryProtocolToolStripMenuItem.Visible = false;
            }

            if (isReset)
            {
                btnConnectDisconnect.Enabled = false;
                helpMenuItem.Enabled = isConnect;
            }
            else
            {
                if (comboBoxReaders.Items.Count > 0)
                    btnConnectDisconnect.Enabled = true;

                btnConnectDisconnect.Text = (isConnect ? "DISCONNECT" : "CONNECT");
                helpMenuItem.Enabled = true;
            }

            if (comboBoxReaders.Items.Count == 0)
            {
                btnConnectDisconnect.Enabled = false;
            }

            settingsMenuItem.Enabled = isConnect;

            txtStopTimer.Enabled = chkTagFocus.Enabled = txtQuietTime.Enabled = chkSelectAll.Enabled = btnInventoryStart.Enabled = isConnect;
            btnInventoryStop.Enabled = false;
            btnPurgeTags.Enabled = isConnect;
            //doubt btnUnquiet.Enabled=btnSetTagQuiet.Enabled = isConnect;
            btnUnquiet.Enabled = btnSetTagQuiet.Enabled = isConnect;
            btnPairNew.Enabled = !isConnect;
            comboBoxReaders.Enabled = !isConnect;
            btnManualConnect.Enabled = !isConnect;
            if (string.IsNullOrEmpty(deviceIdWhichRunsInventory) || (selectedReader != null && deviceIdWhichRunsInventory == selectedReader.ID))
            {
                (tabInventory as Control).Enabled = true;
                if (selectedReader != null && deviceIdWhichRunsInventory == selectedReader.ID)
                {
                    if (isConnect)
                    {
                        btnInventoryStart.Enabled = false;
                        btnInventoryStop.Enabled = true;
                    }
                    else
                    {
                        deviceIdWhichRunsInventory = string.Empty;
                    }
                }
            }
            else
            {
                (tabInventory as Control).Enabled = false;
            }
        }

        private void UpdateUIReaderList(List<IRfidReaderInfo> readerInfoList)
        {
            BeginInvoke((MethodInvoker)delegate
            {
                foreach (IRfidReaderInfo readerInfo in readerInfoList.OrderBy(o => o.FriendlyName))
                {
                    var deviceInfo = CreateReaderInfoItem(readerInfo);
                    readerList.Add(deviceInfo.Reader);

                    var device = new RFIDReaderItem(deviceInfo);

                    comboBoxReaders.Items.Add(device);
                }
                 comboBoxReaders.Refresh();
            });
        }

        private void DiscoverBTDevices()
        {
            Task.Run(() =>
            {
                if (isBluetoothWatcherInitialized)
                {
                    //UpdateStatusMessage("USB reader discovery complete.You may connect to the reader now.");
                    OutputText("Bluetooth reader discovery is in progress...");
                    if(readerList.Count==0 || readerList.FirstOrDefault(ee=>ee.FriendlyName.Contains("Serial"))==null)
                    {
                        UpdateStatusMessage("No USB reader found. Bluetooth reader discovery is in progress.....");
                    }
                    else
                    {
                        UpdateStatusMessage("USB reader can be connected. Bluetooth reader discovery is in progress.....");
                    }
                    List<IRfidReaderInfo> readerInfoList = new List<IRfidReaderInfo>();
                    var remoteReaderInfoList = RFIDLibraryUtility.InitReaderList(ReaderCommunicationMode.Bluetooth);
                    readerInfoList.AddRange(remoteReaderInfoList);
                    UpdateUIReaderList(readerInfoList);
                    OutputText("Bluetooth reader discovery complete.");
                    UpdateStatusMessage("");
                    Invoke((MethodInvoker)delegate
                    {
                        if (comboBoxReaders.Items.Count > 0)
                        {
                            comboBoxReaders.SelectedIndex = 0;
                            btnConnectDisconnect.Enabled = true;
                        }
                        else
                        {
                            btnConnectDisconnect.Enabled = false;
                            UpdateUIControls(false);
                        }
                    });
                }
            });
        }

        private void DiscoverIPDevices()
        {
            Task.Run(() =>
            {
                List<IRfidReaderInfo> readerInfoList = new List<IRfidReaderInfo>();
                if (isIPWatcherInitialized)
                {
                    var ipReaderInfoList = RFIDLibraryUtility.InitReaderList(ReaderCommunicationMode.IP);
                    readerInfoList.AddRange(ipReaderInfoList);
                    UpdateUIReaderList(readerInfoList);
                }
            });
        }

        /// <summary>
        /// Fill reader items into home screen reader comboBox.
        /// </summary>
        private void FillRFIDReadersItems()
        {
            Cursor.Current = Cursors.WaitCursor;
            try
            {
                readerList.Clear();
                comboBoxReaders.Items.Clear();

                
                List<IRfidReaderInfo> readerInfoList = new List<IRfidReaderInfo>();

                //Initialize reader management and reader info list.
                OutputText("USB reader discovery is in progress.....");
                UpdateStatusMessage("USB reader discovery is in progress.....");




                if (isUsbWatcherInitialized)
                {
                    var usbReaderInfoList = RFIDLibraryUtility.InitReaderList(ReaderCommunicationMode.USB);
                    readerInfoList.AddRange(usbReaderInfoList);
                }

                foreach (IRfidReaderInfo readerInfo in readerInfoList.OrderBy(o => o.FriendlyName))
                {
                    var deviceInfo = CreateReaderInfoItem(readerInfo);
                    readerList.Add(deviceInfo.Reader);

                    var device = new RFIDReaderItem(deviceInfo);
                    comboBoxReaders.Items.Add(device);
                }
                OutputText("USB reader discovery complete.");
                //UpdateStatusMessage("USB reader discovery complete.You may connect to the reader now.");
                
                DiscoverBTDevices();
                //DiscoverIPDevices();

                if (comboBoxReaders.Items.Count > 0)
                {
                    comboBoxReaders.SelectedIndex = 0;
                    btnConnectDisconnect.Enabled = true;
                }
                else
                {
                    btnConnectDisconnect.Enabled = false;
                    UpdateUIControls(false);
                }
                Cursor.Current = Cursors.Default;
            }
            catch (Exception ex)
            {
                OutputText("Error discovering scanner: " + ex.Message);
            }
            Cursor.Current = Cursors.Default;
        }

        /// <summary>
        /// Crate local reader info item from SDK reader info object.
        /// </summary>
        /// <param name="readerInfo">The Reader Info object <see cref="IRfidReaderInfo"/></param>
        /// <returns>The reader info object <see cref="RFIDReaderItemInfo"/></returns>
        private RFIDReaderItemInfo CreateReaderInfoItem(IRfidReaderInfo readerInfo)
        {
            //create reader instance based on reader information.
            var reader = RFIDLibraryUtility.CreateReader(readerInfo);

            //creating reader device info object to create reader item on comboBox.
            var deviceInfo = new RFIDReaderItemInfo()
            {
                HostAddress = readerInfo.ID,
                PortNumber = readerInfo.PortNumber,
                FriendlyName = reader.FriendlyName,
                CommunicationMode = readerInfo.CommunicationMode,
                Status = readerInfo.Status,
                Reader = reader,
                ReaderType = readerInfo.ReaderType,
            };

            return deviceInfo;
        }

        /// <summary>
        /// Update active reader status once reader is connected (but not if inventory running in batch mode)
        /// </summary>
        private void UpdateActiveReaderStatus()
        {
            // Check whether connected reader is not in batch mode inventory running state.
            if (ActiveReaderStatus.IsBatchModeInventoryRunning)
            {
                BeginInvoke(new Action(delegate
                {
                    OutputText("Inventory is running in batch mode\n");
                }));
            }
            else
            {
                try
                {
                    // Update the trigger repeat state of the reader based on connected reader start trigger configuration. 
                    ActiveReaderStatus.IsTriggerRepeat = RFIDLibraryUtility.IsTriggerRepeat(selectedReader);

                    // Keep the current batch mode configuration option of connected reader. It is used to make decision when start inventory.
                    ActiveReaderStatus.BatchMode = RFIDLibraryUtility.GetBatchMode(selectedReader);

                    // Use a single flag to determine all the information is retrieved.
                    ActiveReaderStatus.Initialized = true;
                }
                catch
                {
                    ActiveReaderStatus.Initialized = false;
                }
            }
        }

        /// <summary>
        /// Connect the reader using from IP Address and Port or COM port.
        /// </summary>
        private void ManualConnect()
        {
            if (ReaderInfo == null)
                return;

            var deviceInfo = CreateReaderInfoItem(ReaderInfo);
            if (!readerList.Any(r => r.ID == deviceInfo.Reader.ID))
                readerList.Add(deviceInfo.Reader);

            ReaderInfo = null;
            AddToReaderList(deviceInfo, true);

            Connect(deviceInfo);
        }

        /// <summary>
        /// Connect the selected reader.
        /// </summary>
        private void Connect(RFIDReaderItemInfo deviceInfo)
        {
            try
            {
                ActiveReaderStatus.IsInventoryRunning = false;
                SetSelectedReader();

                if (selectedReader.IsConnected)
                {
                    RFIDLibraryUtility.Disconnect(selectedReader);
                }

                Thread connectThread = new Thread(() => StartConnect(deviceInfo));
                connectThread.Start();

                isWaitAnimation = true;

                waitDialog = new WaitAnimation();
                waitDialog.StartPosition = FormStartPosition.CenterParent;
                waitDialog.ShowDialog(this);
            }
            catch (Exception ex)
            {
                OutputText(ex.Message);
                Cursor.Current = Cursors.Default;
            }
        }

        /// <summary>
        /// Initiates a connection to the reader. 
        /// </summary>
        private void StartConnect(RFIDReaderItemInfo deviceInfo)
        {
            try
            {
                RegisterEvents();
                selectedReader.Inventory.AttachTagDataWithTagDataReceivedEvent = true;

                RFIDLibraryUtility.Connect(selectedReader);
                try
                {
                    RFIDLibraryUtility.StopInventory(selectedReader);
                }
                catch { } 
                
                UpdateActiveReaderStatus();

                Invoke((MethodInvoker)delegate
                {
                    OutputText("Status_Notify: Connected.\n");

                    SetSelectedReader();
                    UpdateUIControls(true);

                    EnableImpinjUI(true);
                    //if (selectedReader.ReaderType == ReaderType.RFD)
                    //{
                    //    EnableImpinjUI(true);
                    //}
                    //else
                    //{
                    //    EnableImpinjUI(false);
                    //}
                    Cursor.Current = Cursors.Default;
                    isConnected = true;

                    if (isWaitAnimation)
                    {
                        waitDialog.Close();
                        isWaitAnimation = false;
                    }
                    isConnectedManually = false;
                });
            }
            catch (Exception ex)
            {
                Invoke((MethodInvoker)delegate
                {
                    OutputText(ex.Message);
                    isConnected = false;
                    if (isWaitAnimation)
                    {
                        waitDialog.Close();
                        isWaitAnimation = false;
                    }
                    ActiveReaderStatus.Initialized = false;

                    UpdateUIControls(false);
                    if (isConnectedManually)
                    {
                        readerList.RemoveAll(r => r.ID == deviceInfo.Reader.ID);
                        RemoveFromReaderList(deviceInfo.Reader);
                        isConnectedManually = false;
                    }
                });
            }
        }

        /// <summary>
        /// Disconnect the selected reader.
        /// </summary>
        private void Disconnect()
        {
            try
            {
                if (selectedReader != null)
                {
                    try
                    {
                        RFIDLibraryUtility.StopInventory(selectedReader);
                        BtnPurgeTags_Click(null, null);
                    }
                    catch { }
                    
                    RFIDLibraryUtility.Disconnect(selectedReader);
                    ActiveReaderStatus.Initialized = false;
                    UpdateUIControls(false);
                    //EnableImpinjUI(false);
                }

                // Clean the inventory tag data list
                ResetTagInfo();
                OutputText("Status_Notify: Disconnected.\n");
            }
            catch (Exception ex)
            {
                OutputText(ex.Message);
                Cursor.Current = Cursors.Default;
            }
        }

        /// <summary>
        /// Register event handlers.
        /// </summary>
        private void RegisterEvents()
        {
            selectedReader.TriggerStatusNotification -= SelectedReader_TriggerStatusNotification;
            selectedReader.Inventory.InventoryStarted -= Inventory_InventoryStarted;
            selectedReader.Inventory.InventoryStopped -= Inventory_InventoryStopped;
            selectedReader.Inventory.TagDataReceived -= Inventory_TagDataReceived;
            selectedReader.TriggerStatusNotification += SelectedReader_TriggerStatusNotification;
            selectedReader.Inventory.InventoryStarted += Inventory_InventoryStarted;
            selectedReader.Inventory.InventoryStopped += Inventory_InventoryStopped;
            selectedReader.Inventory.TagDataReceived += Inventory_TagDataReceived;
        }

        private void SetSelectedReader()
        {
            selectedItem = (RFIDReaderItem)comboBoxReaders.SelectedItem;
            selectedReader = readerList.Find(i => i.ID.Equals(selectedItem.Id, StringComparison.OrdinalIgnoreCase));

            if (selectedReader == null)
            {
                throw new ApplicationException("Selected reader should not be null.");
            }
        }

        /// <summary>
        /// Unregister events once reader is disconnected.
        /// </summary>
        private void UnRegisterEvents()
        {
            selectedReader.Inventory.InventoryStarted -= Inventory_InventoryStarted;
            selectedReader.Inventory.InventoryStopped -= Inventory_InventoryStopped;
            selectedReader.Inventory.TagDataReceived -= Inventory_TagDataReceived;
        }

        /// <summary>
        /// Gets the battery, temperature and power of the selected reader.
        /// </summary>
        private void GetDeviceStatus()
        {
            Task.Run(new Action(delegate
            {
                try
                {
                    RFIDLibraryUtility.GetDeviceStatus(selectedReader, true, true, true);
                }
                catch (Exception ex)
                {
                    BeginInvoke(new Action(delegate
                    {
                        OutputText(ex.Message);
                    }));
                }
            }));
        }


        Thread stopInventoryThread;

        /// <summary>
        /// Starts the inventory.
        /// </summary>
        private void StartInventory()
        {
            try
            {
                if (ActiveReaderStatus.IsInventoryRunning)
                {
                    OutputText("Inventory perform already in progress....");
                }
                else
                {
                    // Clean the inventory tag data list
                    //ResetTagInfo();

                    isStopPressed = false;
                    deviceIdWhichRunsInventory = selectedReader.ID;
                    ActiveReaderStatus.IsInventoryRunning = true;


                    try
                    {
                        RFIDLibraryUtility.InventoryPerfom(selectedReader);

                        if (txtStopTimer.Text != "" && txtStopTimer.Text != "0")
                        {
                            //OutputText($"Inventory stop timer set for {txtStopTimer.Text} second(s).");
                            stopInventoryThread = new Thread(StopInventoryThread);
                            stopInventoryThread.IsBackground = true;
                            stopInventoryThread.Start();
                        }
                       
                    }
                    catch (Exception ex)
                    {
                        deviceIdWhichRunsInventory = string.Empty;
                        ActiveReaderStatus.IsInventoryRunning = false;

                        Invoke((MethodInvoker)delegate
                        {
                            OutputText(ex.Message);
                        });
                    }
                    UpdateInventoryButtons();


                    if (ActiveReaderStatus.BatchMode == BATCH_MODE.ENABLE)
                    {
                        BeginInvoke(new Action(delegate
                        {
                            OutputText("Inventory is running in batch mode...");
                        }));
                        ActiveReaderStatus.IsBatchModeInventoryRunning = true;
                    }
                }
            }
            catch (InvalidOperationException ex)
            {
                // While reader is in a busy state from a previous inventory session, if the user attempts to start a new inventory session, the following exceptions is thrown. 
                if (ex.Message.Contains("Unknown read session is in place"))
                {
                    DialogResult result = MessageBox.Show("Unknown inventory is running(in batch mode). Click 'Inventory Stop'",
                                                          "Important",
                                                          MessageBoxButtons.OK,
                                                          MessageBoxIcon.Information,
                                                          MessageBoxDefaultButton.Button2);

                    ActiveReaderStatus.IsBatchModeInventoryRunning = (ActiveReaderStatus.BatchMode != BATCH_MODE.DISABLE);

                    deviceIdWhichRunsInventory = selectedReader.ID;
                    ActiveReaderStatus.IsInventoryRunning = true;

                    UpdateInventoryButtons();
                }
            }
            catch (Exception ex)
            {
                deviceIdWhichRunsInventory = string.Empty;
                ActiveReaderStatus.IsInventoryRunning = false;

                UpdateInventoryButtons();
                OutputText(ex.Message);
            }
        }


        private void StopInventoryThread()
        {
            Console.WriteLine("StopInventoryThread");
            int.TryParse(txtStopTimer.Text, out int seconds);

            DateTime endTime = DateTime.Now.AddSeconds(seconds);

            while (DateTime.Now < endTime && ActiveReaderStatus.IsInventoryRunning)
            {
                Thread.Sleep(100);
            }
            Console.WriteLine($"{DateTime.Now:yyyy-MM-dd HH:mm:ss.fff} - StopInventory-timer expired or inventory stopped");

            if (ActiveReaderStatus.IsInventoryRunning)
            {
                Console.WriteLine($"{DateTime.Now:yyyy-MM-dd HH:mm:ss.fff} - Stop inventory and disable the TagQuietTimer");

                BeginInvoke((MethodInvoker)delegate
                {
                    TagQuietTimer.Stop();
                    isPreSetTagQuiteEnabled = false;

                    try
                    {
                        chkSelectAll.Checked = false;
                        btnUnquiet.Enabled = true;
                        StopInventory();
                        tagQuiet = false;

                        // Use the safe stop method
                        StopUniqueTagTimer();
                    }
                    catch (Exception ex)
                    {
                        OutputText(ex.Message);
                    }
                });
            }
        }


        /// <summary>
        /// Stops the inventory.
        /// </summary>
        private void StopInventory()
        {
            try
            {

                if (ActiveReaderStatus.IsInventoryRunning)
                {
                    isStopPressed = true;
                    Console.WriteLine("RFIDLibraryUtility.StopInventory");
                    RFIDLibraryUtility.StopInventory(selectedReader);
                    deviceIdWhichRunsInventory = string.Empty;
                    ActiveReaderStatus.IsInventoryRunning = false;
                    isAccessSequenceOperationInProgress = false;
                    //UpdateInventoryButtons();
                }
                else
                {
                    OutputText("Already inventory stopped...");
                }
            }
            catch
            {
                deviceIdWhichRunsInventory = selectedReader.ID;
                ActiveReaderStatus.IsInventoryRunning = true;

                UpdateInventoryButtons();
            }
        }

        // Add a flag to prevent re-entrant calls
        private volatile bool isUpdatingInventoryButtons = false;

        /// <summary>
        /// Update inventory start/stop button enable/disable status.
        /// </summary>
        private void UpdateInventoryButtons()
        {
            Console.WriteLine("UpdateInventoryButtons");

            // Prevent re-entrant calls
            if (isUpdatingInventoryButtons)
            {
                Console.WriteLine("UpdateInventoryButtons - already updating, skipping");
                return;
            }

            try
            {
                isUpdatingInventoryButtons = true;

                // Use BeginInvoke instead of Invoke to avoid blocking
                BeginInvoke(new Action(delegate
                {
                    try
                    {
                        if (ActiveReaderStatus.IsInventoryRunning)
                        {
                            btnInventoryStart.Enabled = false;
                            btnInventoryStop.Enabled = true;
                            settingsMenuItem.Enabled = false;
                            txtStopTimer.Enabled = chkSelectAll.Enabled = txtQuietTime.Enabled = btnUnquiet.Enabled = btnSetTagQuiet.Enabled = false;
                            chkEnableFastID.Enabled = false;
                            chkTagFocus.Enabled = false;
                        }
                        else
                        {
                            btnInventoryStart.Enabled = true;
                            btnInventoryStop.Enabled = false;
                            settingsMenuItem.Enabled = true;
                            txtStopTimer.Enabled = chkSelectAll.Enabled = txtQuietTime.Enabled = btnUnquiet.Enabled = btnSetTagQuiet.Enabled = true;
                            chkEnableFastID.Enabled = true;
                            chkTagFocus.Enabled = true;
                        }
                    }
                    finally
                    {
                        isUpdatingInventoryButtons = false;
                    }
                }));
            }
            catch
            {
                isUpdatingInventoryButtons = false;
            }
        }

        /// <summary>
        /// Clean the tag data and inventory list view.
        /// </summary>
        private void ResetTagInfo()
        {

            lock (tagListLock)
            {
                grdTags.Rows.Clear();
                QuiteTagList.Clear();
                tagList.Clear();
            }
            lblTime.Text = "00:00:00";
            lblunqtags.Text = "0";
            lblReadRate.Text = "0";
            lblGray.Text = lblGreen.Text = lblY.Text = lblW.Text = "0";
            m_InventoryStartTime = DateTime.Now;
            chkSelectAll.Checked = false;
            previousUniqueTagCount = 0;     
            lastUniqueTagCheckTime = DateTime.Now;
        }

        /// <summary>
        /// Logging messages into main screen.
        /// </summary>
        /// <param name="txt"></param>
        public void OutputText(string txt)
        {
            try
            {
                Invoke((MethodInvoker)delegate
                {

                    outputLinePos++;
                    if (outputLinePos > MAX_OUTPUT_LINES)
                    {
                        txtOutput.Clear();
                        outputLinePos = 0;
                    }

                    if (!String.IsNullOrEmpty(txt))
                    {
                        txtOutput.SelectionStart = txtOutput.Text.Length;
                        txtOutput.AppendText(txt + Environment.NewLine);
                    }
                });
            }
            catch (Exception ex)
            {
                if (ex is InvalidOperationException)
                {
                    Debug.WriteLine(ex.ToString());
                }
            }
        }

        /// <summary>
        /// Update status message on the main screen.
        /// </summary>
        /// <param name="txt">message</param>
        public void UpdateStatusMessage(string msg)
        {
            try
            {
                Invoke((MethodInvoker)delegate
                {

                    lblStatusMsg.Text = msg;
                });
            }
            catch (Exception ex)
            {
                if (ex is InvalidOperationException)
                {
                    Debug.WriteLine(ex.ToString());
                }
            }
        }

        /// <summary>
        /// Removing the reader from the device combo list when reader is disappeared.(unpaired)
        /// </summary>
        /// <param name="reader"></param>
        private void RemoveFromReaderList(IRfidReader reader)
        {
            bool found = false;
            RFIDReaderItem curItem = null;
            for (int n = 0; n < comboBoxReaders.Items.Count; n++)
            {
                curItem = (RFIDReaderItem)comboBoxReaders.Items[n];
                if (curItem.Id == reader.ID)
                {
                    found = true;
                    break;
                }
            }

            if (found)
            {
                comboBoxReaders.Items.Remove(curItem);
                if (comboBoxReaders.Items.Count == 0)
                {
                    btnConnectDisconnect.Enabled = false;
                }
                else
                {
                    comboBoxReaders.SelectedIndex = 0;
                }
            }
        }

        /// <summary>
        /// Adding from device combo list when reader is appeared. (paired)
        /// </summary>
        /// <param name="deviceInfo"></param>
        private void AddToReaderList(RFIDReaderItemInfo deviceInfo, bool select = false)
        {
            bool found = false;
            for (int n = 0; n < comboBoxReaders.Items.Count; n++)
            {
                RFIDReaderItem item = (RFIDReaderItem)comboBoxReaders.Items[n];
                if ((item.Id == deviceInfo.HostAddress) || (isConnectedManually && item.Text.Contains(deviceInfo.PortNumber)))
                {
                   
                    found = true;
                    if (select)
                    {
                        selectedReader = readerList.Find(i => i.ID.Equals(item.Id, StringComparison.OrdinalIgnoreCase));
                        comboBoxReaders.SelectedIndex = comboBoxReaders.Items.IndexOf(item);
                    }
                    break;
                }
            }

            if (!found)
            {
                RFIDReaderItem item = new RFIDReaderItem(deviceInfo);
                comboBoxReaders.Items.Add(item);

                if (select)
                    comboBoxReaders.SelectedIndex = comboBoxReaders.Items.IndexOf(item);
            }

            if (comboBoxReaders.Items.Count == 1)
            {
                if (!select)
                    comboBoxReaders.SelectedIndex = 0;

                btnConnectDisconnect.Enabled = true;
            }
        }

        /// <summary>
        /// Show singulation control configuration dialog.
        /// </summary>
        private void ShowSingulationDlg()
        {
            Cursor.Current = Cursors.WaitCursor;
            if (selectedReader != null)
            {
                Singulation frm = new Singulation(this);
                frm.Reader = selectedReader;
                frm.ShowDialog();
            }
            Cursor.Current = Cursors.Default;
        }

        /// <summary>
        /// Show pre filters dialog.
        /// </summary>
        private void ShowPreFilter()
        {
            Cursor.Current = Cursors.WaitCursor;
            if (selectedReader != null)
            {
                PreFilters frmConfiguration = new PreFilters(this);
                frmConfiguration.Reader = selectedReader;
                frmConfiguration.ShowDialog();
                DeleteAllPrefilters = frmConfiguration.DeleteAllPreFilters;
                if (DeleteAllPrefilters)
                {
                    chkTagFocus.Checked = false;
                    chkEnableFastID.Checked = false;
                    chkSelectAll.Checked = false;
                }
                if (!frmConfiguration.IsFastIDFilterSelected)
                {
                    chkEnableFastID.Checked = false;
                }

                if (!frmConfiguration.IsTagFocusSelected)
                {
                    chkTagFocus.Checked = false;
                }
            }
            Cursor.Current = Cursors.Default;
        }

        /// <summary>
        /// Pair a new device
        /// </summary>
        private void PairNewReader(IWin32Window owner)
        {
            var dialog = new SelectBluetoothDeviceDialog
            {
                ShowAuthenticated = false,
                ShowRemembered = false,
                ShowUnknown = true,
                AddNewDeviceWizard = true
            };

            dialog.ShowDialog(owner);
        }

        private void ShowDefaultTagData()
        {
            try
            {
                Invoke((MethodInvoker)delegate
                {
                    lock (tagListLock)
                    {
                        foreach (var tagInfo in tagList.Values)
                        {
                            // Validate that the row index is still valid before accessing
                            if (tagInfo.RowIndex >= 0 && tagInfo.RowIndex < grdTags.Rows.Count)
                            {
                                tagInfo.Tag.TagSeenTotalCount = 0;
                                tagInfo.Tag.TagSeenCount = 0;
                                tagInfo.ReadRate = 0;
                                tagInfo.TagSeenTotalCount = 0;
                                tagInfo.TagColor = "W";
                                grdTags["TagSeenCount", tagInfo.RowIndex].Value = 0;
                                grdTags["ReadRate", tagInfo.RowIndex].Value = 0;
                                grdTags.Rows[tagInfo.RowIndex].DefaultCellStyle.BackColor = System.Drawing.Color.White;
                            }
                        }

                        lblTime.Text = "00:00";
                        lblunqtags.Text = grdTags.Rows.Count.ToString();
                        avgReadRate = 0;

                        // Reset unique tag tracking counters
                        previousUniqueTagCount = tagList.Count;
                    }
                });
            }
            catch { }
            
        }

        private void ShowTagData(TagData[] dataArray)
        {
            if(selectedReader!=null && !selectedReader.IsConnected)
                return; 

            foreach (TagData data in dataArray)
            {
                try
                {
                    QuiteTagList.Add(data);
                    if (!tagList.ContainsKey(data.TagID))
                    {
                        int tagRowID = grdTags.Rows.Add();
                        TagInfo tag = new TagInfo(data, tagRowID, data.TagSeenCount);

                        grdTags["TagSelected", tagRowID].Value = false;
                        grdTags["TagID", tagRowID].Value = tag.Tag.TagID;
                        grdTags["PeakRSSI", tagRowID].Value = tag.Tag.PeakRSSI;
                        grdTags["TagSeenCount", tagRowID].Value = (long)tag.Tag.TagSeenCount;  // Cast to long
                        double readrate = Math.Round(tag.Tag.TagSeenCount / (DateTime.Now - m_InventoryStartTime).TotalSeconds, 2);
                        grdTags["ReadRate", tagRowID].Value = readrate;  // Cast to long
                                                                         // Set row color to red if TagSeenCount < 3
                        var color = GetTagRowColor(tag.Tag.TagSeenCount, readrate);
                        grdTags.Rows[tagRowID].DefaultCellStyle.BackColor = color;
                        tag.TagColor = color == System.Drawing.Color.White ? "W" : color == System.Drawing.Color.LightGreen ? "G" : color == System.Drawing.Color.LightGray ? "GR" : "Y";
                        tagList.Add(data.TagID, tag);
                    }
                    else
                    {
                        tagList[data.TagID].Tag = data;
                        tagList[data.TagID].TagSeenTotalCount += tagList[data.TagID].Tag.TagSeenCount;

                        if (tagList[data.TagID].Tag.Selected)
                            grdTags["TagSelected", tagList[data.TagID].RowIndex].Value = true;
                        else
                            grdTags["TagSelected", tagList[data.TagID].RowIndex].Value = false;

                        grdTags["PeakRSSI", tagList[data.TagID].RowIndex].Value = tagList[data.TagID].Tag.PeakRSSI;
                        grdTags["TagSeenCount", tagList[data.TagID].RowIndex].Value = tagList[data.TagID].TagSeenTotalCount;
                        //grdTags["Antenna", tagList[data.TagID].RowIndex].Value = tagList[data.TagID].Tag.AntennaID;
                        double readrate = Math.Round(tagList[data.TagID].TagSeenTotalCount / (DateTime.Now - m_InventoryStartTime).TotalSeconds, 2);


                        grdTags["ReadRate", tagList[data.TagID].RowIndex].Value = readrate;
                        tagList[data.TagID].ReadRate = readrate;
                        // Set row color to red if TagSeenTotalCount < 3
                        var color = GetTagRowColor(tagList[data.TagID].TagSeenTotalCount, readrate);
                        grdTags.Rows[tagList[data.TagID].RowIndex].DefaultCellStyle.BackColor = color;
                        tagList[data.TagID].TagColor = color == System.Drawing.Color.White ? "W" : color == System.Drawing.Color.LightGreen ? "G" : color == System.Drawing.Color.LightGray ? "GR" : "Y";
                    }

                    if (isAccessSequenceOperationInProgress)
                    {
                        grdTags["TagAccessOperations", tagList[data.TagID].RowIndex].Value = data.AccessOperations;
                    }
                }
                catch { }
            }

            //UpdateInventoryTime();

        }

        double avgReadRate = 0;
        private void UpdateInventoryTime()
        {
            Invoke((MethodInvoker)delegate
            {
                var sec = (DateTime.Now - m_InventoryStartTime).TotalSeconds;

                var uniqueCount = grdTags.Rows.Count;
                lblTime.Text = (DateTime.Now - m_InventoryStartTime).ToString(@"hh\:mm\:ss");
                lblunqtags.Text = uniqueCount.ToString();
                long totalTagSeenCount = tagList.Values.Sum(t => t.TagSeenTotalCount);

                var totalReadRates = tagList.Values.Sum(t => t.ReadRate);
                var readRate = Math.Round((totalTagSeenCount / sec), 0);

                lblReadRate.Text = readRate<1?"0": readRate.ToString();
                lblTotalReadCount.Text= totalTagSeenCount.ToString();
                if (totalReadRates > 0)
                {
                    avgReadRate = totalReadRates / uniqueCount;
                }
                else
                {
                    avgReadRate = 0;
                }

                UpdateTagsColorCount();
            });
        }

        private void UpdateTagsColorCount()
        {
            Invoke((MethodInvoker)delegate
            {
                // Count all color categories
                var colorCounts = tagList.Values.GroupBy(t => t.TagColor)
                                            .ToDictionary(g => g.Key, g => g.Count());
                lblY.Text = colorCounts.ContainsKey("Y") ? colorCounts["Y"].ToString() : "0";
                lblW.Text = colorCounts.ContainsKey("W") ? colorCounts["W"].ToString() : "0";
                lblGreen.Text = colorCounts.ContainsKey("G") ? colorCounts["G"].ToString() : "0";
                lblGray.Text = colorCounts.ContainsKey("GR") ? colorCounts["GR"].ToString() : "0";
            });
        }

        private System.Drawing.Color GetTagRowColor(long tagSeenCount, double tagReadRate)
        {
            if (tagSeenCount == 0)
            {
                return System.Drawing.Color.White;
            }
            else if (tagSeenCount == -1)
            {
                return System.Drawing.Color.Yellow;
            }
            else if (tagReadRate < avgReadRate)
            {
                return System.Drawing.Color.LightGray;
            }
            else
            {
                return System.Drawing.Color.LightGreen;
            }
        }


        #endregion

        private void CustomTagQuietingToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (selectedReader != null)
            {
                TagQuieting frmTagQuieting = new TagQuieting(this);
                frmTagQuieting.Reader = selectedReader;
                frmTagQuieting.ShowDialog();
                DeleteAllPrefilters = frmTagQuieting.DeleteAllPreFilters;
                if (DeleteAllPrefilters)
                {
                    chkTagFocus.Checked = false;
                    chkEnableFastID.Checked = false;
                    chkSelectAll.Checked = false;
                }
            }
        }

        private void ProtectedModeToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (selectedReader != null)
            {
                ProtectedMode frmProtectedMode = new ProtectedMode(this);
                frmProtectedMode.Reader = selectedReader;
                frmProtectedMode.ShowDialog();
            }
        }

        private void btnSetTagQuiet_Click(object sender, EventArgs e)
        {
           

            if (quietTagList.Count == 0)
            {
                OutputText("Please select tags to quiet.");
                return;
            }

            if (quietTagList.Count > TAG_QUIET_BATCH_SIZE)
            {
                OutputText("Maximum number of tags exceeded. Cannot quiet more than " + TAG_QUIET_BATCH_SIZE + " tags at a time.");
                return;
            }

            Cursor.Current = Cursors.Default;
            tagQuiet = true;

            isPreSetTagQuiteEnabled = true;
            
            TagQuiet(quietTagList);

            OutputText($"Impinj - Quiet Tags : True");

            if (chkSelectAll.Checked)
            { 
                OutputText($"Starting tag quieting for {quietTagList.Count} tag(s).");      
                btnUnquiet.Enabled = false;
                PerformInventory();
                TagQuietTimer.Interval = 1000 * Int32.Parse(txtQuietTime.Text);
                TagQuietTimer.Start();
            }
            else
            {
                OutputText($"Starting tag quieting for {quietTagList.Count} tag(s).");
                btnUnquiet.Enabled = false;
                PerformInventory();
            }
        }

        private void SetQuitTagColorCode(List<string> tags)
        {
            Invoke((MethodInvoker)delegate
            {
                foreach (var quietTagId in tags)
                {
                    
                    if (tagList.ContainsKey(quietTagId))
                    {
                        var tagInfo = tagList[quietTagId];
                        tagInfo.Tag.Selected = true;
                        grdTags["TagSelected", tagInfo.RowIndex].Value = true;
                        // Update tag info values
                        tagInfo.Tag.TagSeenCount = 0;
                        tagInfo.Tag.TagSeenTotalCount = -1;
                        tagInfo.TagSeenTotalCount = -1;
                        tagInfo.ReadRate = 0;
                        tagInfo.TagColor = "Y";
                        // Update DataGridView cells
                        grdTags["TagSeenCount", tagInfo.RowIndex].Value = -1;
                        grdTags["ReadRate", tagInfo.RowIndex].Value = 0.0;
                        grdTags.Rows[tagInfo.RowIndex].DefaultCellStyle.BackColor = System.Drawing.Color.LightYellow;
                    }
                   
                }
            });
        }


        private void grdTags_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            // Only process if the clicked cell is the TagSelected checkbox column
            if (e.RowIndex >= 0 && e.ColumnIndex == grdTags.Columns["TagSelected"].Index)
            {
                // Commit the edit to get the new value
                grdTags.CommitEdit(DataGridViewDataErrorContexts.Commit);

                string tagID = grdTags["TagID", e.RowIndex].Value?.ToString();
                if (string.IsNullOrEmpty(tagID))
                    return;

                bool isChecked = Convert.ToBoolean(grdTags["TagSelected", e.RowIndex].Value);

                if (isChecked)
                {
                    if (!quietTagList.Contains(tagID))
                    {
                        quietTagList.Add(tagID);
                    }

                    // Check if all eligible tags are now selected
                    CheckIfAllEligibleTagsSelected();
                }
                else
                {
                    // User unchecked a tag - uncheck the Select All checkbox
                    if (chkSelectAll.Checked)
                    {
                        chkSelectAll.CheckedChanged -= chkSelectAll_CheckedChanged;
                        chkSelectAll.Checked = false;
                        chkSelectAll.CheckedChanged += chkSelectAll_CheckedChanged;
                    }

                    if (quietTagList.Contains(tagID))
                    {
                        quietTagList.Remove(tagID);
                    }
                }
            }
        }



        private void grdTags_CellEndEdit(object sender, DataGridViewCellEventArgs e)
        {
            // Only process if the edited cell is the TagSelected checkbox column
            if (e.ColumnIndex == grdTags.Columns["TagSelected"].Index)
            {
                string tagID = grdTags[1, e.RowIndex].Value?.ToString();
                if (string.IsNullOrEmpty(tagID))
                    return;

                bool isChecked = Convert.ToBoolean(grdTags["TagSelected", e.RowIndex].Value);

                if (isChecked)
                {
                    if (!quietTagList.Contains(tagID))
                    {
                        quietTagList.Add(tagID);
                    }

                    // Check if all eligible tags are now selected
                    CheckIfAllEligibleTagsSelected();
                }
                else
                {
                    // User unchecked a tag - uncheck the Select All checkbox
                    if (chkSelectAll.Checked)
                    {
                        chkSelectAll.CheckedChanged -= chkSelectAll_CheckedChanged;
                        chkSelectAll.Checked = false;
                        chkSelectAll.CheckedChanged += chkSelectAll_CheckedChanged;
                    }

                    if (quietTagList.Contains(tagID))
                    {
                        quietTagList.Remove(tagID);
                    }
                }
            }
        }

        /// <summary>
        /// Checks if all eligible tags are selected and updates the Select All checkbox accordingly
        /// </summary>
        private void CheckIfAllEligibleTagsSelected()
        {
            int eligibleTagCount = 0;
            int selectedTagCount = 0;

            // Count eligible tags (TagSeenCount > -1) and selected tags (max 31)
            for (int i = 0; i < grdTags.Rows.Count && eligibleTagCount < 31; i++)
            {
                var tagSeenCountValue = grdTags["TagSeenCount", i].Value;

                long tagSeenCount = 0;
                if (tagSeenCountValue != null)
                {
                    tagSeenCount = Convert.ToInt64(tagSeenCountValue);
                }

                if (tagSeenCount > -1)
                {
                    eligibleTagCount++;

                    bool isSelected = Convert.ToBoolean(grdTags["TagSelected", i].Value ?? false);
                    if (isSelected)
                    {
                        selectedTagCount++;
                    }
                }
            }

            // If all eligible tags are selected, check the Select All checkbox
            if (eligibleTagCount > 0 && selectedTagCount == eligibleTagCount)
            {
                if (!chkSelectAll.Checked)
                {
                    // Temporarily remove event handler to avoid triggering chkSelectAll_CheckedChanged
                    chkSelectAll.CheckedChanged -= chkSelectAll_CheckedChanged;
                    chkSelectAll.Checked = true;
                    chkSelectAll.CheckedChanged += chkSelectAll_CheckedChanged;
                }
            }
        }

        //Impinj Operations
        private void TagQuiet(List<string> tags)
        {

            try
            {
                SetQuitTagColorCode(tags);
                UpdateTagsColorCount();
                    Cursor.Current = Cursors.WaitCursor;
                FILTER_ACTION action = FILTER_ACTION.INV_B_OR_DSRT_SL;
                FILTER_TARGET target = FILTER_TARGET.SESSION_S3;
                List<Filter> readerFilters1 = new List<Filter>();
                selectedReader.PreFilters.ConfiguredFilters = readerFilters1;

                var curFilters = selectedReader.PreFilters.ConfiguredFilters;


                List<Filter> readerFilters = new List<Filter>();
                readerFilters.AddRange(curFilters);

              
                foreach (var tag in tags)
                {
                    Filter f = new Filter()
                    {
                        Action = action,   // 5: FILTER_ACTION.INV_B_OR_DSRT_SL
                        MaskBank = FILTER_MASK_BANK.EPC,
                        Target = target,  // 3: FILTER_TARGET.SESSION_S3
                        MaskStartPos = 2,  // words
                        MatchPattern = DataUtility.HexStringToByteArray(tag),
                        AntennaID = 1,

                    };
                    readerFilters.Add(f);
                    BeginInvoke((MethodInvoker)delegate
                    {
                        OutputText($"Impinj - Quieting : {tag}");
                    });
                }

                try
                {
                    selectedReader.PreFilters.ConfiguredFilters = readerFilters;
                    List<TagQuietMask> TagQuietMasksList = new List<TagQuietMask>();
                    TagQuietMasksList.Add(TagQuietMask.S3B);
                    RFIDLibraryUtility.ImpinjTagQuiet(selectedReader, TagQuietMasksList.ToArray(), FILTER_TARGET.SL_FLAG, FILTER_ACTION.INV_A_OR_ASRT_SL, AntennaID);

                    var singulationControl = new SingulationControl();
                    singulationControl.Session = SESSION.SESSION_S2;
                    singulationControl.State = STATE.AB_FLIP;
                    singulationControl.SLFlag = SL_FLAG.DEASSERTED;
                    RFIDLibraryUtility.SetSingulation(selectedReader, curAntennaIDIndex, singulationControl);
                   
                }
                catch (Exception ex)
                {
                    BeginInvoke((MethodInvoker)delegate { OutputText(ex.Message); });
                }

            }
            catch (Exception ex)
            {
                OutputText(ex.Message);
                Cursor.Current = Cursors.Default;
            }
        }

        private void TagUnquiet()
        {
            try
            {
                // Clear Filters
                List<Filter> readerFilters = new List<Filter>();
                selectedReader.PreFilters.ConfiguredFilters = readerFilters;

                // Unquiet tags
                List<TagQuietMask> tagQuietMasksList = new List<TagQuietMask>();
                tagQuietMasksList.Add(TagQuietMask.S3B);

                RFIDLibraryUtility.ImpinjTagQuiet(selectedReader, tagQuietMasksList.ToArray(), FILTER_TARGET.SL_FLAG, FILTER_ACTION.INV_B_OR_DSRT_SL, AntennaID);
                RFIDLibraryUtility.ImpinjTagQuiet(selectedReader, tagQuietMasksList.ToArray(), FILTER_TARGET.SESSION_S3, FILTER_ACTION.INV_A_OR_ASRT_SL, AntennaID);


                var singulationControl = new SingulationControl();
                singulationControl.Session = SESSION.SESSION_S2;
                singulationControl.State = STATE.AB_FLIP;
                singulationControl.SLFlag = SL_FLAG.DEASSERTED;
                RFIDLibraryUtility.SetSingulation(selectedReader, curAntennaIDIndex, singulationControl);
                quietTagList.Clear();
                BeginInvoke((MethodInvoker)delegate
                {
                    OutputText($"Impinj - Tags  un-quieted");
                    Cursor.Current = Cursors.Default;
                });
            }
            catch (Exception ex)
            {
                OutputText(ex.Message);
                Cursor.Current = Cursors.Default;
            }
        }

        private void ChkTagFocus_CheckedChanged(object sender, EventArgs e)
        {
            try
            {
                Cursor.Current = Cursors.WaitCursor;
                bool focusEnabled = chkTagFocus.Checked;

                if (focusEnabled)
                {
                    chkSelectAll.Checked = false;
                    chkEnableFastID.Checked = false;
                }
               
                SetImpinjTagFocus(focusEnabled);
                ResetTagInfo();

            }
            catch (Exception ex)
            {
                OutputText(ex.Message);
                Cursor.Current = Cursors.Default;
            }
        }

        private void SetImpinjTagFocus(bool focusEnabled)
        {
            try
            {
                RFIDLibraryUtility.ImpinjTagFocus(selectedReader, focusEnabled, AntennaID);

                BeginInvoke((MethodInvoker)delegate
                {
                    OutputText($"Impinj - Tag Focus : {focusEnabled.ToString()}");
                    Cursor.Current = Cursors.Default;
                });
            }
            catch (Exception ex)
            {
                BeginInvoke((MethodInvoker)delegate { OutputText(ex.Message); });
            }
        }


        private void ChkFastID_CheckedChanged(object sender, EventArgs e)
        {
            try
            {
                Cursor.Current = Cursors.WaitCursor;
                bool fastIdEnabled = chkEnableFastID.Checked;

                if (fastIdEnabled)
                {
                    chkSelectAll.Checked = false;   
                    chkTagFocus.Checked = false; 
                }

                SetFastID(fastIdEnabled);
                ResetTagInfo();
            }
            catch (Exception ex)
            {
                OutputText(ex.Message);
                Cursor.Current = Cursors.Default;
            }
        }

        private void SetFastID(bool fastIdEnabled)
        {
            try
            {
                RFIDLibraryUtility.ImpinjFastID(selectedReader, fastIdEnabled, AntennaID);
                ResetTagInfo();
                BeginInvoke((MethodInvoker)delegate
                {
                    OutputText($"Impinj - FastID : {fastIdEnabled.ToString()}");
                    Cursor.Current = Cursors.Default;
                });
            }
            catch (Exception ex)
            {
                BeginInvoke((MethodInvoker)delegate { OutputText(ex.Message); });
            }
        }
        private void chkSelectAll_CheckedChanged(object sender, EventArgs e)
        {
            if (chkSelectAll.Checked)
            {
                //chkEnableFastID.Checked = false;
                //chkTagFocus.Checked = false;
            }

            // First, unselect all tags
            for (int i = 0; i < grdTags.Rows.Count; i++)
            {
                grdTags["TagSelected", i].Value = false;
            }

            quietTagList = new List<string>();

            if (chkSelectAll.Checked)
            {
                // Select only tags with TagSeenCount > 0, max 31 tags
                int selectedCount = 0;
                for (int i = 0; i < grdTags.Rows.Count && selectedCount < 31; i++)
                {
                    var tagSeenCountValue = grdTags["TagSeenCount", i].Value;

                    // Safely convert to long to handle both int and long types
                    long tagSeenCount = 0;
                    if (tagSeenCountValue != null)
                    {
                        tagSeenCount = Convert.ToInt64(tagSeenCountValue);
                    }

                    if (tagSeenCount > -1)
                    {
                        grdTags["TagSelected", i].Value = true;
                        string tagID = grdTags["TagID", i].Value?.ToString() ?? string.Empty;

                        if (!string.IsNullOrEmpty(tagID) && !quietTagList.Contains(tagID))
                        {
                            quietTagList.Add(tagID);
                            selectedCount++;
                        }
                    }
                }
            }
            else
            {
                // Uncheck all and clear quietTagList
                quietTagList.Clear();
            }
        }


        private void TagQuietTimer_Tick(object sender, EventArgs e)
        {
            TagQuietTimer.Stop();

            // Check if we should continue (not stopped by auto-stop timer)
            if (!isPreSetTagQuiteEnabled || !ActiveReaderStatus.IsInventoryRunning)
            {
                OutputText("Tag quiet timer aborted - inventory stopping.");
                return;
            }

            Task.Run(new Action(delegate
            {
                try
                {
                    RFIDLibraryUtility.StopInventory(selectedReader);
                    Thread.Sleep(100);


                    List<Filter> readerFilters = new List<Filter>();
                    selectedReader.PreFilters.ConfiguredFilters = readerFilters;

                    // Reset the list on the UI thread (since ShowTagData writes to it)
                 
                    // Run a short inventory on the background thread
                    if (!ActiveReaderStatus.IsInventoryRunning) return;
                    RFIDLibraryUtility.InventoryPerfom(selectedReader);
                    Thread.Sleep(500);
                    RFIDLibraryUtility.StopInventory(selectedReader);
                    Thread.Sleep(100);

                    // With this code:
                    List<TagData> snapshot = tagList.Values
                        .Where(t => t.Tag.TagSeenTotalCount >=0)
                        .Select(t => t.Tag)
                        .ToList();

                    List<TagData> listToUncheck = tagList.Values
                        .Where(t => t.Tag.TagSeenTotalCount <=0)
                        .Select(t => t.Tag)
                        .ToList();

                    // Replace the existing code section with this loop:
                    foreach (var tagData in listToUncheck)
                    {
                        if (tagList.ContainsKey(tagData.TagID))
                        {
                            var tagInfo = tagList[tagData.TagID];
                            grdTags["TagSelected", tagInfo.RowIndex].Value = false;
                            tagInfo.Tag.Selected = false;
                        }
                    }


                    if (snapshot.Count > 0)
                    {
                        BeginInvoke((MethodInvoker)delegate
                        {
                            OutputText($"Impinj - Tags to quiet : {snapshot.Count}");
                        });

                        List<string> tags = snapshot
                            .Take(31)
                            .Select(t => t.TagID.ToString())
                            .ToList();

                        TagQuiet(tags);
                        Thread.Sleep(100);

                        if (!ActiveReaderStatus.IsInventoryRunning) return;
                        RFIDLibraryUtility.InventoryPerfom(selectedReader);
                    }
                    else
                    {
                        BeginInvoke((MethodInvoker)delegate
                        {
                            OutputText($"Impinj - No tags to quiet");
                        });
                        RFIDLibraryUtility.InventoryPerfom(selectedReader);
                    }

                    BeginInvoke((MethodInvoker)delegate
                    {
                        TagQuietTimer.Start();
                    });
                }
                catch 
                {
                   
                }
            }));
        }


        private void button1_Click(object sender, EventArgs e)
        {
            chkSelectAll.Checked = false;
            chkEnableFastID.Checked = false;
            chkTagFocus.Checked = false;
            TagUnquiet();
            tagQuiet = false;
        }

        private void EnableImpinjUI(bool impinjUIEnable)
        {
            if (impinjUIEnable)
            {
                chkEnableFastID.Visible = true;
                chkTagFocus.Visible = true;
                btnSetTagQuiet.Visible = true;
                txtQuietTime.Visible = true;
                lblQuiet.Visible = true;
                btnUnquiet.Visible = true;
                customTagQuietingToolStripMenuItem.Visible = true;
                protectedModeToolStripMenuItem.Visible = true;
            }
            else
            {
                chkEnableFastID.Visible = false;
                chkTagFocus.Visible = false;
                btnSetTagQuiet.Visible = false;
                txtQuietTime.Visible = false;
                lblQuiet.Visible = false;
                btnUnquiet.Visible = false;
                customTagQuietingToolStripMenuItem.Visible = false;
                protectedModeToolStripMenuItem.Visible = false;
            }
        }

        private void frmMain_FormClosed(object sender, FormClosedEventArgs e)
        {
            try
            {
                if(selectedReader!=null && selectedReader.IsConnected)
                RFIDLibraryUtility.StopInventory(selectedReader);
            }
            catch { }
        }

        private void settingsMenuItem_Click(object sender, EventArgs e)
        {

        }
        private void NumericTextBox_TextChanged(object sender, EventArgs e)
        {
            var textBox = (System.Windows.Forms.TextBox)sender;
            string filtered = new string(textBox.Text.Where(char.IsDigit).ToArray());
            if (filtered != textBox.Text)
            {
                int cursor = textBox.SelectionStart;
                textBox.Text = filtered;
                textBox.SelectionStart = Math.Max(0, cursor - 1);
            }


            if ((textBox == txtStopTimer || textBox == txtQuietTime) && !string.IsNullOrEmpty(textBox.Text))
            {
                if (!long.TryParse(textBox.Text, out long value) || value > int.MaxValue)
                {
                    textBox.Text = int.MaxValue.ToString();
                    textBox.SelectionStart = textBox.Text.Length;
                }
            }
        }

        private void txtStopTimer_KeyPress(object sender, KeyPressEventArgs e)
        {
            // Allow only digits, backspace, and control keys
            // Disallow minus sign and other characters
            if (!char.IsControl(e.KeyChar) && !char.IsDigit(e.KeyChar))
            {
                e.Handled = true;
            }
        }

        private void txtQuietTime_KeyPress(object sender, KeyPressEventArgs e)
        {
            // Allow only digits, backspace, and control keys
            // Disallow minus sign and other characters
            if (!char.IsControl(e.KeyChar) && !char.IsDigit(e.KeyChar))
            {
                e.Handled = true;
            }
        }

        private void grdTags_CellMouseClick(object sender, DataGridViewCellMouseEventArgs e)
        {
            // Check if the click is a right-click and ignore header rows/columns (-1)
            if (e.Button == MouseButtons.Right && e.RowIndex >= 0 && e.ColumnIndex >= 0)
            {
                // Select the right-clicked cell so the user sees what they copied
                grdTags.CurrentCell = grdTags.Rows[e.RowIndex].Cells[e.ColumnIndex];

                // Get the cell value safely
                object cellValue = grdTags.Rows[e.RowIndex].Cells[e.ColumnIndex].Value;

                if (cellValue != null && cellValue != DBNull.Value)
                {
                    // Copy the text to the clipboard
                    Clipboard.SetText(cellValue.ToString());
                }
            }
        }
    }
}
