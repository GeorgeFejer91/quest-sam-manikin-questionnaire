package org.questquestionnaire.sam2d;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import android.content.Context;

import org.json.JSONObject;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.RuntimeEnvironment;
import org.robolectric.annotation.Config;

import java.nio.file.Files;

@RunWith(RobolectricTestRunner.class)
@Config(sdk = 35)
public final class SamContractTest {
    @Test
    public void scoreFractionMapsToNineChoices() {
        assertEquals(1, SamScaleView.scoreFromFraction(0.0f));
        assertEquals(1, SamScaleView.scoreFromFraction(0.001f));
        assertEquals(2, SamScaleView.scoreFromFraction(1f / 9f + 0.001f));
        assertEquals(5, SamScaleView.scoreFromFraction(4.4f / 9f));
        assertEquals(9, SamScaleView.scoreFromFraction(0.999f));
        assertEquals(9, SamScaleView.scoreFromFraction(1.5f));
    }

    @Test
    public void exporterWritesSamAndSliderValues() throws Exception {
        Context context = RuntimeEnvironment.getApplication();
        SamLaunchContext launch = SamLaunchContext.fromIntent(null);
        SamResponseRecord record = SamResponseRecord.create(launch, 100L);
        record.inputPath = "unit-test";
        record.valenceScore = 9;
        record.arousalScore = 3;
        record.valenceLabel = SamResponseRecord.valenceLabel(record.valenceScore);
        record.arousalLabel = SamResponseRecord.arousalLabel(record.arousalScore);
        record.valenceResponseTimestampUtc = TimeUtil.utcIsoNowMillis();
        record.arousalResponseTimestampUtc = TimeUtil.utcIsoNowMillis();
        record.valenceResponseUnixMs = TimeUtil.unixMillisNow();
        record.arousalResponseUnixMs = TimeUtil.unixMillisNow();
        record.valenceResponseElapsedMs = 120L;
        record.arousalResponseElapsedMs = 130L;
        record.sliderValence = 75;
        record.sliderArousal = 25;
        record.sliderValenceResponseTimestampUtc = TimeUtil.utcIsoNowMillis();
        record.sliderArousalResponseTimestampUtc = TimeUtil.utcIsoNowMillis();
        record.sliderValenceResponseUnixMs = TimeUtil.unixMillisNow();
        record.sliderArousalResponseUnixMs = TimeUtil.unixMillisNow();
        record.sliderValenceResponseElapsedMs = 140L;
        record.sliderArousalResponseElapsedMs = 150L;
        record.submittedUnixMs = TimeUtil.unixMillisNow();
        record.submittedElapsedMs = 160L;

        SamExporter.ExportResult result = SamExporter.writeSession(context, record);
        JSONObject json = new JSONObject(readUtf8(result.jsonFile.toPath()));
        assertEquals("quest-questionnaire.sam2d.export.v3", json.getString("schema"));
        assertEquals("previous_session", json.getString("ratingTarget"));
        assertEquals(9, json.getJSONObject("sam").getInt("valenceRaw1To9"));
        assertEquals(3, json.getJSONObject("sam").getInt("arousalRaw1To9"));
        assertEquals(1.0, json.getJSONObject("sam").getDouble("valenceNormalized0To1"), 0.0001);
        assertEquals(0.25, json.getJSONObject("sam").getDouble("arousalNormalized0To1"), 0.0001);
        assertEquals(75, json.getJSONObject("affectiveSlider").getInt("valenceRaw0To100"));
        assertEquals(25, json.getJSONObject("affectiveSlider").getInt("arousalRaw0To100"));
        String csv = readUtf8(result.csvFile.toPath());
        assertTrue(csv.contains("ratingTarget"));
        assertTrue(csv.contains("previous_session"));
        assertTrue(csv.contains("sam_valence_raw_1_9"));
        assertTrue(csv.contains("as_arousal_raw_0_100"));
    }

    private static String readUtf8(java.nio.file.Path path) throws Exception {
        return new String(Files.readAllBytes(path), java.nio.charset.StandardCharsets.UTF_8);
    }
}
